defmodule VendingMachineApp.Product do
  use Ecto.Schema

    schema "products" do
      field :name, :string
      field :type, :string
      field :price, :float
      field :quantity, :integer
      has_many :vending_machines, VendingMachineApp.VendingMachine

      timestamps()
    end

    def decrease_quantity(product_id, quantity_change) do
      Ecto.Multi.new()
      |> Ecto.Multi.update(Product, product_id, quantity: field(`quantity`) - ^quantity_change)
      |> Repo.transaction()
    end

    def changeset(product, attrs \\ %{}) do
      product
      |> cast(attrs, [:name, :type, :price, :quantity])
    end

    def create_product(attrs) do
      changeset(%Product{}, attrs)
      |> Repo.insert()
    end
  end
