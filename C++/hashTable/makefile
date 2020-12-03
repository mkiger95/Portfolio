# CS 302 Assignment #7
# Make file for product reviews project

#OBJS	= reviews.o reviewData.o
OBJS1 = hashTest.o hashTable.o
CC	= g++ -Wall -pedantic -g -std=c++11
#DEPS	= reviewData.h hashTable.h
DEPS1	= hashTable.h

all: hashTest

hashTest.o: hashTest.cpp $(DEPS1)
		$(CC) -c hashTest.cpp

hashTable.o: hashTable.cpp $(DEPS1)
	$(CC) -c hashTable.cpp

hashTest: hashTest.o hashTable.o $(DEPS1)
	$(CC) -o hashTest $(OBJS1)


reviews.o: reviews.cpp $(DEPS)
	$(CC) -c reviews.cpp

reviewData.o: reviewData.cpp $(DEPS)
	$(CC) -c reviewData.cpp

reviews: reviews.o reviewData.o $(DEPS)
	$(CC) -o reviews $(OBJS)

# -----
# clean by removing object files.

clean:
	rm	$(OBJS)
