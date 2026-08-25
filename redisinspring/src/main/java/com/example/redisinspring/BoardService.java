package com.example.redisinspring;

import java.util.List;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

@Service
public class BoardService {

    private final BoardRepository boardRepository;
    
    public BoardService(BoardRepository boardRepository) {
        this.boardRepository = boardRepository;
    }

    @Cacheable(cacheNames = "getBoards", key = "'boards:page:' + #page + ':size:' + #size", cacheManager = "boardCacheManager")
    public List<Boards> getBoards(Integer page, Integer size) {
            
        System.out.println("page: " + page + ", size: " + size);
        Pageable pageable = PageRequest.of(page, size);
        Page<Boards> pageBoards = boardRepository.findAllByOrderByCreatedAtDesc(pageable);
        return pageBoards.getContent();
    
    }
}