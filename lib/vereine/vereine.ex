defmodule Vereine do
  alias Vereine.Aggregates.Antrag

  alias Vereine.Commands.{
    SubmitApplication,
    AddFeature,
    FinalizeApplication
  }

  def submit_antrag(attrs) do
    attrs
    |> SubmitApplication.new()
    |> SubmitApplication.add_id()
    |> Antrag.dispatch()
  end

  def allow_employment(antrag_id) do
    %{id: antrag_id, feature: :employeer}
    |> AddFeature.new()
    |> Antrag.dispatch()
  end

  def allow_funding(antrag_id) do
    %{id: antrag_id, feature: :fundable}
    |> AddFeature.new()
    |> Antrag.dispatch()
  end

  def finalize_antrag(antrag_id) do
    %{id: antrag_id}
    |> FinalizeApplication.new()
    |> Antrag.dispatch()
  end
end
