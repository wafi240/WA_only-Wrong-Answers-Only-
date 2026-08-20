# WAOnly — Competitive Programming Platform

WAOnly is a terminal-based competitive programming platform built in C++17.
It features a custom implementation of all core data structures and logic.

## Features
- **Authentication**: Secure login and registration.
- **Problem Bank**: Browse, filter, and solve problems.
- **Submission Manager**: Track your progress and view history.
- **Unlock System**: Problems have prerequisites; solve them to unlock more.
- **Contest Hub**: Participate in contests with live leaderboards.
- **Rating Engine**: Elo-like rating system with titles and colors.
- **CodFetch**: View solutions of other users for problems you've solved.
- **Profile**: View and compare player stats.
- **Division System**: Players are grouped into Div 1, Div 2, and Div 3.

## Core Data Structures (Custom Built)
- Hash Table (Polynomial rolling hash, chaining, dynamic resizing)
- AVL Tree (Self-balancing BST for rating-based search)
- Doubly Linked List
- Max Heap (Contest standings)
- Graph (Dependency management, topological sort, BFS/DFS)
- DSU (Union-find for divisions)
- Stack & Queue
- Binary Search & Sorting (MergeSort, QuickSort)

## Build & Run
```bash
make build
make run
```

## Run Tests
```bash
make test
```

## Default Admin
- **Username**: admin
- **Password**: admin123
