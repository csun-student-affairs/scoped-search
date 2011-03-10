class ScopedSearch
  class UndefinedScopeError < StandardError; end
  class UnsupportedORMError < StandardError; end  
  
  module Model
    module ClassMethods
      # by default, scopes will be generated for all attributes
      # pass a single value, or an array of values to specify which attributes to create scopes for
      # examples :
      #     generate_search_scopes                # same as `include ScopedSearch::Generator`
      #     generate_search_scopes :name
      #     generate_search_scopes :name, :email
      def generate_search_scopes(*args)
        # TODO: add scoped_search_generator_opts[:orm]
        if defined?(Mongoid) && self <= Mongoid::Document        
          field_names = [*args]
          field_names = :all if field_names.blank?
          @scoped_search_generator_opts = {:for => field_names}
          self.send :include, ScopedSearch::Generator
        else
          raise UnsupportedORMError.new "Sorry, generate_search_scopes is not supported yet for ActiveRecord. Coming soon. In the meanwhile, please define your own scopes inside your ActiveRecord model."
        end
      end
    end
  end
  
  module Generator
    extend ActiveSupport::Concern

    module ClassMethods
      def method_missing(method_name, *args, &block)
        # check if method name matches any generated scope names
        if name_matches_generated_scope?(method_name)  # define the scope and return the result
          define_scope_for( extract_scope_symbols_from(method_name) )
          self.send(method_name, *args)              
        else # not one of the scopes, so pass on
          super              
        end
      end
      
      def respond_to?(method_name, include_private = false)
        name_matches_generated_scope?(method_name) ? true : super
      end  

      def scoped_search_generator_opts
        @scoped_search_generator_opts ||= {:for => :all}
      end

      # calculate when called to catch fields created after inclusion of this module
      def generated_scope_fields
        scoped_search_generator_opts[:for] == :all ? self.fields.keys : [* @scoped_search_generator_opts[:for] ]
      end     
      
      def generated_scopes # don't memoize to ensure it's always up to date
        returner = {}
        generated_scope_lambdas.each_pair do |name, lambda_block|
          returner[name] = Mongoid::Scope.new(lambda_block)
        end
        
        returner
      end

      # override to include generated scopes
      def scopes
        super.merge!(generated_scopes)
      end
      
      
             
      private       
        # field_name and scope_name must be Symbol
        def define_scope_for(opts={:field => nil, :scope => nil})
          name = "#{opts[:field]}_#{opts[:scope]}".to_sym
          scope name, generated_scope_lambdas[name]
        end

        # defines the following scopes
        #   field_equals
        #   field_does_not_equal
        #   field_like        
        #   field_matches   # same as _equals for Mongoid, accepts regexp or array
        #   field_greater_than
        #   field_greater_than_or_equal_to
        #   field_less_than
        #   field_less_than_or_equal_to       
        def generated_scope_definitions
          @generated_scope_definitions ||= {
            :matches                  => {}, # regex match            
            :equals                   => {},
            :does_not_equal           => {:predicate  => '.ne'        },
            :like                     => {:regex      => '/params/i'  }, # will be converted to regexp
            :greater_than             => {:predicate  => '.gt'        },
            :greater_than_or_equal_to => {:predicate  => '.gte'       },
            :less_than                => {:predicate  => '.lt'        },
            :less_than_or_equal_to    => {:predicate  => '.lte'       }
          }          
        end
         
        def generated_scope_lambdas # don't memoize to ensure it's always up to date
          returner = {} 
          generated_scope_fields.each do |field_name|
            generated_scope_definitions.each_pair do |scope_name, opts|
              predicate = opts[:predicate].to_s.dup
              v = opts.has_key?(:regex) ? opts[:regex].gsub('params', '#{s}') : 's'
              lambda_string = "lambda { |s| where(:#{field_name}#{predicate} => #{v})}"
              returner["#{field_name}_#{scope_name}".to_sym] = eval(lambda_string)
            end
          end

          returner 
        end

        def generated_scope_names
          @generated_scope_names ||= generated_scopes.keys.map(&:to_s).sort.map(&:to_sym)
        end

        def generated_scope_names_regex
          field_names_regex = generated_scope_fields.map(&:to_s).join('|')
          scope_names_regex = generated_scope_definitions.keys.map(&:to_s).join('|')
          /^(#{field_names_regex})_(#{scope_names_regex})$/
        end

        def name_matches_generated_scope?(name)
          name.to_s =~ generated_scope_names_regex 
        end

        def extract_scope_symbols_from(method_name)
          match = generated_scope_names_regex.match(method_name.to_s)
          raise UndefinedScopeError.new(method_name) if match.nil?
          {:field => match[1].to_sym, :scope => match[2].to_sym} 
        end
    end 
  end
end