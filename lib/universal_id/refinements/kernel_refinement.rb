# frozen_string_literal: true

module UniversalID::Refinements::KernelRefinement
  refine Kernel do
    # Finds a constant by name, starting at the root namespace (i.e. ::Object)
    def const_find(name)
      return nil unless name.is_a?(String)
      names = name.split("::")
      constant = Object

      while names.any?
        value = names.shift
        constant = constant.const_get(value) if constant.const_defined?(value)
      end

      (constant.name == name) ? constant : nil
    end
  end
end
