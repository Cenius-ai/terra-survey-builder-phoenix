defmodule TerraWeb.CoreComponents do
  use Phoenix.Component

  attr :class, :string, default: nil
  attr :rest, :global

  def button(assigns) do
    ~H"""
    <button
      class={[
        "inline-flex items-center justify-center rounded-lg px-4 py-2.5 text-sm font-semibold",
        "bg-accent text-on-accent hover:opacity-90",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
        "disabled:opacity-50 disabled:cursor-not-allowed",
        "transition-colors duration-150",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  attr :class, :string, default: nil
  attr :rest, :global

  def button_secondary(assigns) do
    ~H"""
    <button
      class={[
        "inline-flex items-center justify-center rounded-lg px-4 py-2.5 text-sm font-semibold",
        "bg-secondary text-on-secondary hover:opacity-80",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
        "disabled:opacity-50 disabled:cursor-not-allowed",
        "transition-colors duration-150",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  attr :class, :string, default: nil
  attr :rest, :global

  def button_destructive(assigns) do
    ~H"""
    <button
      class={[
        "inline-flex items-center justify-center rounded-lg px-4 py-2.5 text-sm font-semibold",
        "bg-destructive text-on-destructive hover:opacity-90",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
        "disabled:opacity-50 disabled:cursor-not-allowed",
        "transition-colors duration-150",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  slot :inner_block, required: true
  attr :class, :string, default: nil

  def card(assigns) do
    ~H"""
    <div class={["bg-card text-card-foreground rounded-xl border border-border shadow-sm", @class]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :name, :string, required: true
  attr :label, :string, default: nil
  attr :type, :string, default: "text"
  attr :value, :any, default: nil
  attr :placeholder, :string, default: nil
  attr :required, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  def input(assigns) do
    ~H"""
    <div class={@class}>
      <label
        :if={@label}
        for={@name}
        class="block text-sm font-medium text-foreground mb-1.5"
      >
        <%= @label %>
      </label>
      <input
        type={@type}
        name={@name}
        id={@name}
        value={@value}
        placeholder={@placeholder}
        required={@required}
        class={[
          "w-full rounded-lg border border-border bg-card px-3.5 py-2.5 text-sm text-foreground",
          "placeholder:text-muted-foreground",
          "focus:outline-none focus:ring-2 focus:ring-ring focus:border-transparent",
          "transition-colors duration-150"
        ]}
        {@rest}
      />
    </div>
    """
  end

  attr :name, :string, required: true
  attr :label, :string, default: nil
  attr :value, :any, default: nil
  attr :placeholder, :string, default: nil
  attr :required, :boolean, default: false
  attr :rows, :integer, default: 3
  attr :class, :string, default: nil
  attr :rest, :global

  def textarea(assigns) do
    ~H"""
    <div class={@class}>
      <label
        :if={@label}
        for={@name}
        class="block text-sm font-medium text-foreground mb-1.5"
      >
        <%= @label %>
      </label>
      <textarea
        name={@name}
        id={@name}
        placeholder={@placeholder}
        required={@required}
        rows={@rows}
        class={[
          "w-full rounded-lg border border-border bg-card px-3.5 py-2.5 text-sm text-foreground",
          "placeholder:text-muted-foreground",
          "focus:outline-none focus:ring-2 focus:ring-ring focus:border-transparent",
          "transition-colors duration-150",
          "resize-y"
        ]}
        {@rest}
      ><%= @value %></textarea>
    </div>
    """
  end

  attr :name, :string, required: true
  attr :label, :string, default: nil
  attr :value, :any, default: nil
  attr :options, :list, default: []
  attr :class, :string, default: nil
  attr :rest, :global

  def select(assigns) do
    ~H"""
    <div class={@class}>
      <label
        :if={@label}
        for={@name}
        class="block text-sm font-medium text-foreground mb-1.5"
      >
        <%= @label %>
      </label>
      <select
        name={@name}
        id={@name}
        class={[
          "w-full rounded-lg border border-border bg-card px-3.5 py-2.5 text-sm text-foreground",
          "focus:outline-none focus:ring-2 focus:ring-ring focus:border-transparent",
          "transition-colors duration-150"
        ]}
        {@rest}
      >
        <%= for {label, val} <- @options do %>
          <option value={val} selected={@value == val}><%= label %></option>
        <% end %>
      </select>
    </div>
    """
  end

  attr :class, :string, default: nil

  def badge(assigns) do
    ~H"""
    <span class={[
      "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold",
      "bg-secondary text-on-secondary",
      @class
    ]}>
      <%= render_slot(@inner_block) %>
    </span>
    """
  end

  attr :class, :string, default: nil

  def badge_accent(assigns) do
    ~H"""
    <span class={[
      "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold",
      "bg-accent/15 text-accent",
      @class
    ]}>
      <%= render_slot(@inner_block) %>
    </span>
    """
  end
end
