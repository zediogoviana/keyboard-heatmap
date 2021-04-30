defmodule KeyHeatmap do
  def main(args) do
    args |> parse_args |> process
  end

  def process(file: path, type: type, model: model) do
    with {:ok, contents} <- File.read(path) do
      frequencies = KeyLogParser.perform(contents)
      type_atom = String.to_atom(type)
      model_atom = String.to_atom(model)

      with {:ok, keyboard} <- Layouts.get_keyboard_layout(type_atom, model_atom) do
        Painter.perform(frequencies, keyboard)
      end
    end
  end

  def process(_) do
    IO.inspect("Argumentos inválidos")
    {:error, :no_valid_args}
  end

  defp parse_args(args) do
    {options, _, _} =
      OptionParser.parse(args,
        switches: [file: :string, type: :string, model: :string]
      )

    options
  end
end
