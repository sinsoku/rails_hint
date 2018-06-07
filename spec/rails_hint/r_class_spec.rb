# frozen_string_literal: true

RSpec.describe RailsHint::RClass do
  describe ".search" do
    context "a class" do
      let(:content) do
        <<~USER
          class User < ApplicationRecord
          end
        USER
      end
      before { allow(File).to receive(:read) { content } }
      let(:classes) { described_class.search("user.rb") }

      it "includes a User class" do
        expect(classes.size).to eq 1

        klass = classes[0]
        expect(klass.name).to eq "User"
        expect(klass.super_name).to eq "ApplicationRecord"
        expect(klass.path).to eq "user.rb"
      end
    end

    context "multiple classes in a file" do
      let(:content) do
        <<~USER
          class ApplicationRecord < ActiveRecord::Base
          end

          class User < ApplicationRecord
          end
        USER
      end
      before { allow(File).to receive(:read) { content } }
      let(:classes) { described_class.search("user.rb") }

      it { expect(classes.size).to eq 2 }

      it "includes a ApplicationRecord class" do
        klass = classes[0]
        expect(klass.type).to eq :class
        expect(klass.name).to eq "ApplicationRecord"
        expect(klass.super_name).to eq "ActiveRecord::Base"
      end

      it "includes a User class" do
        klass = classes[1]
        expect(klass.type).to eq :class
        expect(klass.name).to eq "User"
        expect(klass.super_name).to eq "ApplicationRecord"
      end
    end

    context "a class under namespaces" do
      let(:content) do
        <<~USER
          module Foo
            module Bar
              class User < ApplicationRecord
              end
            end
          end
        USER
      end
      before { allow(File).to receive(:read) { content } }
      let(:classes) { described_class.search("user.rb") }

      it { expect(classes.size).to eq 3 }

      it "includes a Foo module" do
        klass = classes[0]
        expect(klass.type).to eq :module
        expect(klass.name).to eq "Foo"
        expect(klass.super_name).to be_nil
      end

      it "includes a Bar module" do
        klass = classes[1]
        expect(klass.type).to eq :module
        expect(klass.name).to eq "Foo::Bar"
        expect(klass.super_name).to be_nil
      end

      it "includes a User class" do
        klass = classes[2]
        expect(klass.type).to eq :class
        expect(klass.name).to eq "Foo::Bar::User"
        expect(klass.super_name).to eq "ApplicationRecord"
      end
    end

    context "using open class" do
      let(:content) do
        <<~USER
          class User
          end
          class User
          end
        USER
      end
      before { allow(File).to receive(:read) { content } }
      let(:classes) { described_class.search("user.rb") }

      it { expect(classes.size).to eq 1 }
    end
  end
end
