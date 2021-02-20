class Array

    alias oldIndexing []
    alias oldMap map

    def [](index)
        if oldIndexing(index) == nil
            return '\0'
        else
            return oldIndexing(index)
        end
    end

    def map(seq=nil, &block)
        if seq.nil?
            oldMap &block
        else
            arr = self[seq]
            arr.map &block
        end
    end

end
