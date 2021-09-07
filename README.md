# select
Implementation of four variants of Dijkstra’s guarded-if, written in Smalltalk.

The variants include:
- **any**: Evaluate all the guards. Evaluate any one of the blocks with a true guard. If no guard is true,
evaluate the block of the else clause if it is present.
- **first**: Evaluate the guards in order, from first to last. Upon encountering the first true guard, evaluate
its associated block and stop evaluating guards. If no guard is true, evaluate the block of the else
clause if it is present. Note that this is like the familiar if … else if … else semantics.
- **all**: Evaluate the guards, in order, from first to last. After each guard evaluation, when the guard is
true, evaluate its associated block. If no guard is true, evaluate the block of the else clause if it is
present.
- **exclusive**: Evaluate all the guards. If exactly one guard is true, evaluate its associated block. If no
guard is true, evaluate the block of the else clause, if it is present.

Written for Hamilton College's Computer Science 220 (Principles of Programming Languages) course.
