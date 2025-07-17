//
//  TestActor.swift
//  ModernConcurrency
//
//  Created by lucas van Dongen on 20/06/2025.
//

import AsyncAlgorithms

@globalActor actor TestActor: GlobalActor {
    static let shared = TestActor()
}

@TestActor
class Worker {
    let channel = AsyncChannel<Bool>()
    func work() async -> Bool {
        await channel.send(true)
        return true
    }
}

@MainActor
class ViewModel {
    @TestActor var worker = Worker()

    init() {
        Task(priority: .background) { @TestActor in
            await bla()
        }

        Task {
            await click()
        }
    }

    func bla() async {
        for await unsafe bool in await worker.channel {
            print(bool)
        }
    }

    func click() async {
        _ = await worker.work()
    }
}
