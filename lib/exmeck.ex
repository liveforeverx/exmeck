defmodule Exmeck.Mock do

  defmacro __using__(opts // []) do
    mockfunctions = quote do
      Module.register_attribute __MODULE__, :__mockfuncs__, persist: false, accumulate: true
    end
    other = lc {attr, opt} inlist [__mockmodule__: :mock,
                                   __options__: :options,
                                   __start_fun__: :start_fun] do
      quote do
        Module.register_attribute __MODULE__, unquote(attr), persist: false, accumulate: false
        Module.put_attribute __MODULE__, attr, unquote(opts[opt])
      end
    end
    quote do
      unquote(mockfunctions)
      unquote(other)
      @before_compile unquote(__MODULE__)
      import unquote(__MODULE__)
    end
  end

  defmacro mock(func, _options // [], body) do
    {funcname, _, args} = func
    argslen = len(args)
    quote do
      @__mockfuncs__ {unquote(funcname), unquote(argslen)}
      def unquote(func), unquote(body)
    end
  end

  defp len(nil), do: 0
  defp len(list), do: length(list)

  defmacro __before_compile__(env) do
    module_attrs = [:__mockfuncs__, :__mockmodule__, :__options__, :__start_fun__]
    [mockFunctions, mock, options, name] =
      lc attr inlist module_attrs do
        Module.get_attribute(env.module, attr)
      end
    unless name, do: name = :_mocking
    functions = lc {func, length} inlist mockFunctions do
      quote do
        :meck.expect(
          unquote(mock),
          unquote(func),
          function(__MODULE__, unquote(func), unquote(length))
        )
      end
    end
    quote do
      def unquote(name), unquote(
          do: {:__block__, [],
            [(quote do: :meck.new(unquote(mock), unquote(options))) | functions]}
        )
    end
  end

end
