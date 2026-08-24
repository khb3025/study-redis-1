package com.example.radisinspring;

import java.util.List;


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

    public List<Board> getBoards(Integer page, Integer size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<Board> pageBoards = boardRepository.findAllByOrderByCreatedAtDesc(pageable);
        return pageBoards.getContent();
    }
}