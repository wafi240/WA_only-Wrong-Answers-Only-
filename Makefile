CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra -g
INCLUDES = -Isrc/data -Isrc/logic -Isrc/io -Isrc/features -Iassets/checker -I.

SRCS = src/main.cpp \
       src/logic/graph.cpp \
       src/io/file_parser.cpp \
       src/io/utils.cpp \
       src/features/auth.cpp \
       src/features/problem_bank.cpp \
       src/features/submission_manager.cpp \
       src/features/leaderboard.cpp \
       src/features/contest_manager.cpp \
       src/features/unlock_system.cpp \
       src/features/division_manager.cpp \
       src/features/file_creator.cpp \
       src/features/ai_assistant.cpp \
       src/features/rating_engine.cpp \
       src/features/profile.cpp \
       src/features/codfetch.cpp \
       src/features/globals.cpp \
       assets/checker/checker.cpp

OBJS = $(SRCS:.cpp=.o)
TARGET = waonly

build: $(TARGET)

$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) $(INCLUDES) -o $@ $^

%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

run: build
	./$(TARGET)

test:
	$(CXX) $(CXXFLAGS) $(INCLUDES) tests/*.cpp $(filter-out src/main.cpp, $(SRCS)) -o run_tests
	./run_tests

clean:
	find . -name "*.o" -delete
	rm -f $(TARGET) run_tests
