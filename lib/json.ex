defmodule LoadFest.Json do
  import Enum

  def event() do
    %{
      "manufacturer" => manu(),
      "temp" => temp(),
      "customer" => %{
        "id" => "Qsx78Xfd",
        "location" => %{
          "address" => "123 W Main St",
          "city" => "Phoenix",
          "state" => "AZ",
          "zip" => 85016
        }
      },
      "tags" => tags(),
      "type" => "fridge",
      "door_status" => door()
    }
  end

  defp manu(), do: random(["Zenith", "Sub Zero", "Wolf", "Bosch", "Kitchen Aid"])
  defp temp(), do: random(1..100)
  defp tags(), do: take(all_tags(), 3)

  defp all_tags(),
    do: shuffle(["stand-alone", "commercial", "restaurant", "glass-doors"])

  defp door(), do: random(["open", "closed"])
end
