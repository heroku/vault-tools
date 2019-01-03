module Vault
  # Pipes and Filters implementations
  #
  # Individual filters do work with ::call(object)
  #
  # Compose a Pipeline with the ::use method
  #
  # Example:
  #
  #   Pricer = Class.new(Pipeline)
  #
  #   class AppTierPricer < Pricer
  #     use PlanScoper, Quantizer, AppGrouper
  #     use UserGrouper
  #   end
  class Pipeline
    def self.use(*args)
      @filters ||= []
      @filters.push *args
    end

    def self.filters
      @filters ||= nil
    end

    def self.process(thing)
      return thing unless filters
      filters.each do |filter|
        thing = filter.call(thing)
        yield thing, filter if block_given?
      end
      thing
    end
  end
end
