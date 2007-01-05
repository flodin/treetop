require 'rubygems'
require 'spec/runner'

dir = File.dirname(__FILE__)
require "#{dir}/spec_helper"

context "A new grammar" do
  setup do
    @grammar = Grammar.new
  end

  specify "returns an instance of Parser in response to new_parser" do
    @grammar.new_parser.should_be_an_instance_of(Parser)
  end
  
  specify "returns unique parsers in response to repeated calls to new_parser" do
    @grammar.new_parser.should_be_an_instance_of(Parser)
  end
  
  specify "returns parsers that retain a reference to that grammar" do
    @grammar.new_parser.grammar.should_equal @grammar
  end
  
  specify "retains an explicitly set root even if the first parsing rule is added " +
          "subsequently to it being set" do
    alt_root = mock("Alternate root nonterminal")
    @grammar.root = alt_root
    @grammar.root.should_equal alt_root
    @grammar.add_parsing_rule(make_parsing_rule)
    @grammar.root.should_equal alt_root
  end
  
  specify "constructs or returns a previously constructed a nonterminal symbol " +
          "with a reference to itself on call to nonterminal_symbol" do
    ruby_sym = :foo
    nonterminal = @grammar.nonterminal_symbol(ruby_sym)
    nonterminal.grammar.should_equal(@grammar)
    @grammar.nonterminal_symbol(ruby_sym).should_equal nonterminal
  end
  
  specify "constructs a parsing rule automatically if add_parsing_rule is called with " +
          "a nonterminal symbol and a parsing expression" do
    ruby_sym = :foo
    nonterminal = @grammar.nonterminal_symbol(ruby_sym)
    expression = TerminalSymbol.new("foo")
    @grammar.add_parsing_rule(nonterminal, expression)
    @grammar.get_parsing_expression(nonterminal).should_equal expression
  end
end

context "A grammar with a parsing rule" do
  setup do
    @grammar = Grammar.new
    @rule = make_parsing_rule
    @grammar.add_parsing_rule(@rule)
  end
  
  specify "can retrive the parsing expression associated with that rule based on " +
          "its nonterminal symbol" do
    @grammar.get_parsing_expression(@rule.nonterminal_symbol).should_equal @rule.parsing_expression
  end
  
  specify "is rooted at that parsing rule's nonterminal because it was the first " +
          "added and no root was explicitly set" do
    @grammar.root.should_equal @rule.nonterminal_symbol
  end
  
  specify "is rooted at a different root if one is explicitly set" do
    alt_root = mock("Alternate root nonterminal")
    @grammar.root = alt_root
    @grammar.root.should_equal alt_root
  end
end

def make_parsing_rule
  nonterminal = NonterminalSymbol.new(:foo, @grammar)
  ParsingRule.new(nonterminal, mock("Parsing expression"))
end