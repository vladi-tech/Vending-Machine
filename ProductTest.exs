defmodule VendingMachineApp.ProductTest do
  use ExUnit.Case

  test "add a new product" do
    product = %VendingMachineApp.Product{name: "Chocolate", type: "Sweet", price: 2.50, quantity: 1000}
    assert {:ok, _} = VendingMachineApp.Product.create_product(product)
  end

  test "get all products" do
    products = VendingMachineApp.Product.get_all_products()
    assert length(products) > 0
  end
end
