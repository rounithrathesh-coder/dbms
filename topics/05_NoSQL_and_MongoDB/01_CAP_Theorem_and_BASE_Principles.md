-- Topic Query Reference: 2026-07-14
# CAP Theorem and BASE Properties in Distributed Systems

## Brewer's CAP Theorem
In a distributed asynchronous network subject to partitions ($P$), a data store can guarantee at most two of:
1. **Consistency ($C$)**: Every read receives the most recent write or an error.
2. **Availability ($A$)**: Every non-failing node returns a non-error response.
3. **Partition Tolerance ($P$)**: System functions despite arbitrary network partitions.

## BASE Properties (vs ACID)
- **Basically Available**: Availability is preserved through decentralized replica nodes.
- **Soft State**: System state may drift over time without immediate synchronization.
- **Eventual Consistency**: Replicas converge given sufficient convergence time.
