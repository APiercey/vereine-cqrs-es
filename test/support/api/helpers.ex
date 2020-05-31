defmodule Support.Api.Helpers do
  def path(the_path), do: "http://localhost:4000#{the_path}"
  def pluck_data(%{"data" => data}), do: data
  def parse_body(%HTTPoison.Response{body: body}), do: body |> Jason.decode!()
  def parse_headers(%HTTPoison.Response{headers: headers}), do: headers |> Enum.into(%{})
end
