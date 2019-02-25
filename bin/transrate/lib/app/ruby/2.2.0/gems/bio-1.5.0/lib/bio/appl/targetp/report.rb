#
# = bio/appl/targetp/report.rb - TargetP report class
# 
# Copyright::  Copyright (C) 2003 
#              Mitsuteru C. Nakao <n@bioruby.org>
# License::    The Ruby License
#
#  $Id:$
#
# == Description
#
# TargetP class for http://www.cbs.dtu.dk/services/TargetP/
#
# == Example
# == References
#

module Bio


  class TargetP

    # = A parser and container class for TargetP report.
    class Report

      # Delimiter
      DELIMITER = "\n \n"

      # Delimiter      
      RS = DELIMITER

      # Returns the program version.
      attr_reader :version
      
      # Returns the query sequences.
      attr_reader :query_sequences

      # Returns 'included' or 'not included'.
      # If the value is 'included', Bio::TargetP::Report#prediction['TPlen']
      # contains a valid value.
      attr_reader :cleavage_site_prediction
      
      # Returns ``PLANT'' or ``NON-PLANT'' networks.
      attr_reader :networks

      # Returns a Hash of the prediction results.
      #
      # {"Name"=>"MGI_2141503", "Loc."=>"_", "RC"=>3, "SP"=>0.271,
      #  "other"=>0.844, "mTP"=>0.161, "cTP"=>0.031, "Length"=>640}
      # 
      # Keys: Name, Len, SP, mTP, other, Loc, RC
      # Optional key for PLANT networks: cTP
      # Optional key in Cleavage site: TPlen
      #
      # Use 'Length' and 'Loc.' instead of 'Len' and 'Loc' respectively
      # for the version 1.0 report.
      attr_reader :prediction

      # Returns a Hash of cutoff values.
      attr_reader :cutoff

      # Sets output report.
      def initialize(str)
        @version                  = nil
        @query_sequences          = nil
        @cleavage_site_prediction = nil
        @networks                 = nil
        @prediction               = {}
        @cutoff                   = {}
        parse_entry(str)
      end

      alias pred prediction

      # Returns the name of query sequence.
      def name
        @prediction['Name']
      end
      alias entry_id name 

      # Returns length of query sequence.
      def query_len
        if @prediction['Len']
          @prediction['Len']
        else
          @prediction['Length']
        end
      end
      alias length query_len

      # Returns the predicted localization signal: 
      # 1. S (Signal peptide)
      # 2. M (mTP)
      # 3. C (cTP)
      # 4. * 
      # 5. _
      def loc
        if @prediction['Loc'] 
          @prediction['Loc']   # version 1.0
        else
          @prediction['Loc.']  # version 1.1
        end
      end

      # Returns RC.
      def rc
        @prediction['RC']
      end
      
      private

      # 
      def parse_entry(str)
        labels = []
        cutoff = []
        values = []

        str.split("\n").each {|line|
          case line
          when /targetp v(\d+.\d+)/,/T A R G E T P\s+(\d+.\d+)/
            @version = $1

          when /Number of (query|input) sequences:\s+(\d+)/
            @query_sequences = $1.to_i

          when /Cleavage site predictions (\w.+)\./ 
            @cleavage_site_prediction = $1

          when /Using (\w+.+) networks/
            @networks = $1
          when /Name +Len/
            labels = line.sub(/^\#\s*/,'').split(/\s+/)

          when /cutoff/
            cutoff = line.split(/\s+/)
            cutoff.shift
            labels[2, 4].each_with_index {|loc, i|
              next if loc =~ /Loc/
              @cutoff[loc] = cutoff[i].to_f
            }
          when /-----$/
          when /^ +$/, ''
          else
            values = line.sub(/^\s*/,'').split(/\s+/)
            values.each_with_index {|val, i|
              label = labels[i]
              case label
              when 'RC', /Len/ 
                val = val.to_i
              when 'SP','mTP','cTP','other'
                val = val.to_f
              end
              @prediction[label] = val
            }
          end
        }
      end

    end # class Report
    
  end # class TargetP

end # moudel Bio

