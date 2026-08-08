defmodule TerraWeb.ErrorHTML do
  use TerraWeb, :html

  def render(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
