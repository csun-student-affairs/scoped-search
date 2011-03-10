require 'spec_helper'

if ENV["ORM"] == "mongoid"
  require 'mongoid'
  
  class MongoidModel
    include Mongoid::Document
    include ScopedSearch::Model
    
    field :name
    field :email
    field :age, :type => Integer
  end

  class ARModel
    include ScopedSearch::Model
  end

  describe ScopedSearch::Generator do
    it "should raise an error if including class is not a Mongoid Document" do
      expect { ARModel.send(:generate_search_scopes) }.to raise_error(ScopedSearch::UnsupportedORMError)
    end
  
    it "should not respond to a generated scope name before inclusion" do
      MongoidModel.respond_to?(:name_equals).should be_false
    end
  
    context "after inclusion" do
      def expected_criteria(conditions)
        Mongoid::Criteria.new(MongoidModel).where(conditions)
      end
    
      before :all do 
        MongoidModel.send(:generate_search_scopes)
        @model_class = MongoidModel
      end
    
      it "should include generated scopes in scopes" do
        generated_scope_names = @model_class.send :generated_scope_names
        (generated_scope_names & @model_class.scopes.keys).should == generated_scope_names
      end
    
      # use a different approach from above to ensure all scopes are created as expected
      it "should generate scopes for fields that are not defined at time of inclusion" do
        expected_scope_names = @model_class.send(:generated_scope_definitions).keys.map do |scope|
          %w{ name email age }.map { |field| "#{field}_#{scope}".to_sym }
        end.flatten
      
        (expected_scope_names & @model_class.scopes.keys).should == expected_scope_names
      end    
    
      it "should respond to a generated scope name after inclusion" do
        @model_class.respond_to?(:name_equals).should be_true
      end

      it "should generate _equals scope" do
        @model_class.name_equals('Dr. Foobar').should == expected_criteria(:name => 'Dr. Foobar')
      end
    
      it "should generate _matches scope" do
        @model_class.name_matches(/o+/).should == expected_criteria(:name => /o+/)
      end    
        
      it "should generate _like scope" do
        @model_class.name_like('Foobar').should == expected_criteria(:name => /Foobar/i)
      end    
    
      context "with predicates" do
        it "should generate _does_not_equal scope" do
          @model_class.age_does_not_equal(30).should == expected_criteria(:age.ne => 30)
        end      
      
        it "should generate _greater_than scope" do
          @model_class.age_greater_than(30).should == expected_criteria(:age.gt => 30)
        end      
      
        it "should generate _greater_than_or_equal_to scope" do
          @model_class.age_greater_than_or_equal_to(30).should == expected_criteria(:age.gte => 30)
        end      
      
        it "should generate _less_than scope" do
          @model_class.age_less_than(30).should == expected_criteria(:age.lt => 30)
        end      
      
        it "should generate _less_than_or_equal_to scope" do
          @model_class.age_less_than_or_equal_to(30).should == expected_criteria(:age.lte => 30)
        end      
      end  
    end
  end
end