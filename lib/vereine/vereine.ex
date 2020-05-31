defmodule Vereine do
  alias Vereine.Aggregates.Application

  alias Vereine.Commands.{
    SubmitApplication,
    AddFeature,
    FinalizeApplication
  }

  def submit_application(attrs) do
    attrs
    |> SubmitApplication.new()
    |> SubmitApplication.add_id()
    |> Application.dispatch()
  end

  def allow_employment(application_id) do
    %{id: application_id, feature: :employeer}
    |> AddFeature.new()
    |> Application.dispatch()
  end

  def allow_funding(application_id) do
    %{id: application_id, feature: :fundable}
    |> AddFeature.new()
    |> Application.dispatch()
  end

  def finalize_application(application_id) do
    %{id: application_id}
    |> FinalizeApplication.new()
    |> Application.dispatch()
  end
end
