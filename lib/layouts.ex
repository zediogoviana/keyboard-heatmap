defmodule Layouts do
  def get_keyboard_layout(model, keyboard) do
    case model do
      :keychron -> keyboard_layout(Layouts.Keychron, keyboard)
      # :macbook -> keyboard_layout(Layouts.Macbook, keyboard)
      :niz -> keyboard_layout(Layouts.Niz, keyboard)
      _ -> {:error, :no_model}
    end
  end

  defp keyboard_layout(module, keyboard) do
    function_list =
      module.__info__(:functions)
      |> Enum.into(%{})

    if Map.has_key?(function_list, keyboard) do
      {:ok, apply(module, keyboard, [])}
    else
      {:error, :no_keyboard}
    end
  end
end
