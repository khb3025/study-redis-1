package com.example.radisinspring;

import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Page;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BoardRepository extends JpaRepository<Boards, Long> {
    Page<Boards> findAllByOrderByCreatedAtDesc(Pageable pageable);
}
