---
%{
  published_at: ~D[2020-09-21],
  title: "Use Ecto Embedded Schemas to Back Phoenix Forms",
  categories: ["elixir"],
  image: "/images/phoenix-forms-with-ecto-embedded-schema.webp"
}
---
Phoenix has been pushing separation of concerns through it's defaults by generating
`project` and `project_web` directories and defaulting generators to use contexts.
Since we should be separating our web application logic from our core application logic,
I have started using embedded ecto schemas to create form modules in my projects.

This enables us to to separate our frontend data model representations from our
schema data model. One of the most common suggestions for implementing a proper 
user authentication system is to add a virtual password field to the schema. Now,
any time we get a user from the database, we have an empty password field in our
struct! Wouldn't it be better if we could encrypt the password in the registration
form and pass it directly to our schema's changeset?

Once you've started separating these data models, it opens up a lot more options
to accept the input the user expects but save it in our database like our data 
model expects.

In this example, we're going to make a product creation form for an online store
that accepts the price of the product as a decimal (e.g. "$49.99") but saves it 
in our database as an integer (e.g. 4999).

Let's start with the new product action. Let's make a `ProductForm` module that
gives us an empty form. We'll use Ecto's `embedded_schema` to give us an easy to
use struct that isn't backed by a database table.

```elixir
defmodule StoreWeb.ProductForm do
  use Ecto.Schema

  import Ecto.Changeset

  @required [:name, :price]
  @attributes @required ++ [:description]
  @primary_key false

  embedded_schema do
    field :name, :string
    field :price, :string
    field :description, :string
  end

  @spec form :: Ecto.Changeset.t()
  def form, do: cast(%__MODULE__{}, %{}, @attributes)
end
```

And now, in our controller, we can pass our function down to the template to be
rendered by `form_for`.

```elixir
defmodule StoreWeb.ProductController do
  use StoreWeb, :controller

  @spec new(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def new(conn, _params) do
    changeset = StoreWeb.ProductForm.form()

    render(conn, "new.html", changeset: changeset)
  end
end
```

The form works, but now we need to hook it up to our create action. Our store's
data API accepts a map of attributes to the `create_product` function. So let's
add a function to handle that.

```elixir
defmodule StoreWeb.ProductForm do
  use Ecto.Schema

  import Ecto.Changeset

  @required [:name, :price]
  @attributes @required ++ [:description]
  @primary_key false

  embedded_schema do
    field :name, :string
    field :price, :string
    field :description, :string
  end

  @spec form :: Ecto.Changeset.t()
  def form, do: cast(%__MODULE__{}, %{}, @attributes)

  @spec form :: Ecto.Changeset.t()
  def form, do: form(%{})

  @spec form(map()) :: Ecto.Changeset.t()
  def form(attributes) do
    cast(%__MODULE__{}, attributes, @attributes)
  end

  @spec attributes(Ecto.Changeset.t()) :: {:ok, map()} | {:error, Ecto.Changeset.t()}
  def attributes(form) do
    applied = apply_action(form, :create)

    case applied do
      {:ok, struct} -> {:ok, Map.from_struct(struct)}
      other -> other
    end
  end
end
```

Now let's plug this in to our create action.

```elixir
defmodule StoreWeb.ProductController do
  use StoreWeb, :controller

  @spec create(Plug.Conn.t(), map) :: Plug.Conn.t()
  def create(conn, %{"product_form" => product_params}) do
    form = StoreWeb.ProductForm.form(product_params)

    with {:ok, attributes} <- StoreWeb.ProductForm.attributes(form),
         {:ok, product} <- Store.create_product(attributes) do
      conn
      |> put_flash(:info, "Product created successfully.")
      |> redirect(to: Routes.product_path(conn, :show, product))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
```

We've got a problem now: our attributes are passing the price as a string but our
API is expecting an integer. Let's fix this and add some more validations:

```elixir
defmodule StoreWeb.ProductForm do
  # omitted for length

  @price_regex ~r/^\$?(?<dollars>\d*)(\.?(?<cents>\d{1,2}))?$/

  @spec attributes(Ecto.Changeset.t()) :: {:ok, map()} | {:error, Ecto.Changeset.t()}
  def attributes(form) do
    applied =
      form
      |> validate_required(@required)
      |> validate_format(:price, @price_regex, message: "must be a price ($19.99)")
      |> apply_action(:create)

    case applied do
      {:ok, struct} ->
        attributes =
          struct
          |> Map.from_struct()
          |> price_to_int()

        {:ok, attributes}

      other ->
        other
    end
  end

  defp price_to_int(%{price: price} = attributes) do
    [cents, dollars] = Regex.run(@price_regex, price, capture: :all_names)

    int_dollars = if dollars == "", do: 0, else: String.to_integer(dollars) * 100
    int_cents = if cents == "", do: 0, else: String.to_integer(cents)
    int_price = int_dollars + int_cents

    %{attributes | price: int_price}
  end
end
```

Now we need to use the form in our edit and update actions. We'll want to make
sure to display our price as a decimal string again. Here's our final form module.

```elixir
defmodule StoreWeb.ProductForm do
  use Ecto.Schema

  import Ecto.Changeset

  @price_regex ~r/^\$?(?<dollars>\d*)(\.?(?<cents>\d{1,2}))?$/

  @required [:name, :price]
  @attributes @required ++ [:description]
  @primary_key false

  embedded_schema do
    field :name, :string
    field :price, :string
    field :description, :string
  end

  @spec form :: Ecto.Changeset.t()
  def form, do: form(%{})

  @spec form(map() | %Store.Product{}) :: Ecto.Changeset.t()
  def form(%_{} = struct), do: form(struct, %{})

  def form(attributes) do
    form(%__MODULE__{}, attributes)
  end

  @spec form(%__MODULE__{} | %Store.Product{}, map()) :: Ecto.Changeset.t()
  def form(%__MODULE__{} = form, attributes) do
    form
    |> int_to_price()
    |> cast(attributes, @attributes)
  end

  def form(%_{} = struct, attributes) do
    merged_attributes =
      struct
      |> Map.from_struct()
      |> int_to_price()
      |> Map.merge(attributes)

    form(%__MODULE__{}, merged_attributes)
  end

  @spec attributes(Ecto.Changeset.t()) :: {:ok, map()} | {:error, Ecto.Changeset.t()}
  def attributes(form) do
    applied =
      form
      |> validate_required(@required)
      |> validate_format(:price, @price_regex, message: "must be a price ($19.99)")
      |> apply_action(:create)

    case applied do
      {:ok, struct} ->
        attributes =
          struct
          |> Map.from_struct()
          |> price_to_int()

        {:ok, attributes}

      other ->
        other
    end
  end

  defp price_to_int(%{price: price} = attributes) do
    [cents, dollars] = Regex.run(@price_regex, price, capture: :all_names)

    int_dollars = if dollars == "", do: 0, else: String.to_integer(dollars) * 100
    int_cents = if cents == "", do: 0, else: String.to_integer(cents)
    int_price = int_dollars + int_cents

    %{attributes | price: int_price}
  end

  defp int_to_price(%{price: int_price} = struct) when is_integer(int_price) do
    price =
      "$" <>
        to_string(Integer.floor_div(int_price, 100)) <>
        "." <> to_string(Integer.mod(int_price, 100))

    %{struct | price: price}
  end

  defp int_to_price(struct), do: struct
end
```

And here it is plugged in to our controller actions.

```elixir
defmodule StoreWeb.ProductController do
  use StoreWeb, :controller

  @spec new(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def new(conn, _params) do
    changeset = StoreWeb.ProductForm.form()

    render(conn, "new.html", changeset: changeset)
  end

  @spec create(Plug.Conn.t(), map) :: Plug.Conn.t()
  def create(conn, %{"product_form" => product_params}) do
    form = StoreWeb.ProductForm.form(product_params)

    with {:ok, attributes} <- StoreWeb.ProductForm.attributes(form),
         {:ok, product} <- Store.create_product(attributes) do
      conn
      |> put_flash(:info, "Product created successfully.")
      |> redirect(to: Routes.product_path(conn, :show, product))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  @spec edit(Plug.Conn.t(), map) :: Plug.Conn.t()
  def edit(conn, %{"id" => id}) do
    product = Store.get_product!(id)
    changeset = StoreWeb.ProductForm.form(product)

    render(conn, "edit.html", product: product, changeset: changeset)
  end

  @spec update(Plug.Conn.t(), map) :: Plug.Conn.t()
  def update(conn, %{"id" => id, "product_form" => product_params}) do
    product = Store.get_product!(id)
    form = StoreWeb.ProductForm.form(product, product_params)

    with {:ok, attributes} <- StoreWeb.ProductForm.attributes(form),
         {:ok, product} <- Store.update_product(product, attributes) do
      conn
      |> put_flash(:info, "Product updated successfully.")
      |> redirect(to: Routes.product_path(conn, :show, product))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", product: product, changeset: changeset)
    end
  end
end
```
