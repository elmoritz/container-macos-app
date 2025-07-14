import SwiftUI
import Containerization

// Simple model to track container and its state
struct ContainerInfo: Identifiable {
    let id: String
    let container: LinuxContainer
    var isRunning: Bool
}

public struct ContentView: View {
    @State private var containers: [ContainerInfo] = []
    @State private var isLoading = true
    
    public var body: some View {
        VStack {
            Text("Running Containers")
                .font(.largeTitle)
                .padding()
            if isLoading {
                ProgressView("Loading containers...")
            } else if containers.isEmpty {
                Text("No running containers found.")
                    .foregroundColor(.secondary)
            } else {
                List(containers) { info in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(info.id)
                                .font(.headline)
                            Text(info.isRunning ? "Running" : "Stopped")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if info.isRunning {
                            Button("Stop") {
                                stopContainer(info)
                            }
                            .buttonStyle(.borderedProminent)
                        } else {
                            Button("Start") {
                                startContainer(info)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }
        }
        .onAppear(perform: loadContainers)
        .frame(minWidth: 400, minHeight: 300)
    }
    
    public init() {}
    
    private func loadContainers() {
        isLoading = true
        // TODO: Replace with actual logic to discover containers
        // For demo, create a sample container (replace with real logic)
        Task {
            // Example: create a dummy container (replace with real rootfs and vmm)
            let dummyRootfs = Mount.any(type: "tmpfs", source: "tmpfs", destination: "/", options: ["mode=1777"])
            let vmm = VirtualMachineManager()
            let container = LinuxContainer(UUID().uuidString, rootfs: dummyRootfs, vmm: vmm)
            let info = ContainerInfo(id: container.id, container: container, isRunning: false)
            containers = [info]
            isLoading = false
        }
    }
    
    private func startContainer(_ info: ContainerInfo) {
        Task {
            do {
                try await info.container.create()
                try await info.container.start()
                updateContainerState(id: info.id, running: true)
            } catch {
                // Handle error
            }
        }
    }
    
    private func stopContainer(_ info: ContainerInfo) {
        Task {
            do {
                try await info.container.stop()
                updateContainerState(id: info.id, running: false)
            } catch {
                // Handle error
            }
        }
    }
    
    private func updateContainerState(id: String, running: Bool) {
        if let idx = containers.firstIndex(where: { $0.id == id }) {
            containers[idx].isRunning = running
        }
    }
}
