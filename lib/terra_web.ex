defmodule TerraWeb do
  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  def router do
    quote do
      use Phoenix.Router, helpers: false
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, formats: [:html, :json]
      import Plug.Conn
    end
  end

  def html do
    quote do
      use Phoenix.Component

      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      import Phoenix.HTML
      import Phoenix.HTML.Form
      import TerraWeb.CoreComponents

      alias Phoenix.LiveView.JS
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {TerraWeb.Layouts, :app}

      import Phoenix.HTML
      import Phoenix.HTML.Form
      import TerraWeb.CoreComponents

      alias Phoenix.LiveView.JS
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      import Phoenix.HTML
      import Phoenix.HTML.Form
      import TerraWeb.CoreComponents

      alias Phoenix.LiveView.JS
    end
  end

  def component do
    quote do
      use Phoenix.Component

      import Phoenix.HTML
      import Phoenix.HTML.Form
      import TerraWeb.CoreComponents

      alias Phoenix.LiveView.JS
    end
  end
end
