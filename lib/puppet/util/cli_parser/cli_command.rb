# Autogenerated from a Treetop grammar. Edits may be lost.


module CliCommand
  include Treetop::Runtime

  def root
    @root ||= :command
  end

  include CliPath

  module Command0
    def arguments
      elements[1]
    end

  end

  module Command1
    def path
      elements[0]
    end

    def method
      elements[2]
    end

    def arguments
      elements[3]
    end
  end

  module Command2
    def value
      result = [path.value, method.text_value]
      if arguments
       result += [arguments.text_value]
      end

      result
    end
  end

  def _nt_command
    start_index = index
    if node_cache[:command].has_key?(index)
      cached = node_cache[:command][index]
      if cached
        node_cache[:command][index] = cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_path
    s0 << r1
    if r1
      if (match_len = has_terminal?(':', false, index))
        r2 = true
        @index += match_len
      else
        terminal_parse_failure(':')
        r2 = nil
      end
      s0 << r2
      if r2
        r3 = _nt_method
        s0 << r3
        if r3
          i5, s5 = index, []
          if (match_len = has_terminal?('(', false, index))
            r6 = true
            @index += match_len
          else
            terminal_parse_failure('(')
            r6 = nil
          end
          s5 << r6
          if r6
            r7 = _nt_arguments
            s5 << r7
            if r7
              if (match_len = has_terminal?(')', false, index))
                r8 = true
                @index += match_len
              else
                terminal_parse_failure(')')
                r8 = nil
              end
              s5 << r8
            end
          end
          if s5.last
            r5 = instantiate_node(SyntaxNode,input, i5...index, s5)
            r5.extend(Command0)
          else
            @index = i5
            r5 = nil
          end
          if r5
            r4 = r5
          else
            r4 = instantiate_node(SyntaxNode,input, index...index)
          end
          s0 << r4
        end
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(Command1)
      r0.extend(Command2)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:command][start_index] = r0

    r0
  end

  def _nt_arguments
    start_index = index
    if node_cache[:arguments].has_key?(index)
      cached = node_cache[:arguments][index]
      if cached
        node_cache[:arguments][index] = cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    s0, i0 = [], index
    loop do
      if has_terminal?(@regexps[gr = '\A[^)]'] ||= Regexp.new(gr), :regexp, index)
        r1 = true
        @index += 1
      else
        terminal_parse_failure('[^)]')
        r1 = nil
      end
      if r1
        s0 << r1
      else
        break
      end
    end
    r0 = instantiate_node(SyntaxNode,input, i0...index, s0)

    node_cache[:arguments][start_index] = r0

    r0
  end

  def _nt_method
    start_index = index
    if node_cache[:method].has_key?(index)
      cached = node_cache[:method][index]
      if cached
        node_cache[:method][index] = cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    r0 = _nt_identifier

    node_cache[:method][start_index] = r0

    r0
  end

end

class CliCommandParser < Treetop::Runtime::CompiledParser
  include CliCommand
end

