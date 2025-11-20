---
name: Replicated CLI
description: This skill should be used when the user asks to "create a Replicated release", "promote a release", "manage CMX VMs", "create a CMX cluster", "SSH to a CMX VM", "install Embedded Cluster", "lint Replicated manifests", "execute commands on CMX VMs", or mentions Replicated release workflows, VM testing, or compatibility matrix operations.
version: 0.1.0
---

# Replicated CLI

This skill provides guidance for working with the Replicated CLI tool, which enables vendors to create releases, manage customer deployments, and test applications using Replicated's Compatibility Matrix (CMX) VM infrastructure.

## Overview

The Replicated CLI (`replicated`) is the primary tool for:
- Creating and promoting application releases
- Managing CMX test VMs and clusters
- Testing Embedded Cluster installations
- Configuring channels and customer instances
- Automating release workflows

## Core Concepts

### Releases and Channels

**Releases** are versioned snapshots of application manifests (KOTS YAML, Helm charts, etc.) that can be promoted to channels for customer deployment.

**Channels** represent deployment tracks (e.g., `stable`, `beta`, `unstable`) that customers subscribe to for updates.

### CMX (Compatibility Matrix) Infrastructure

CMX provides two types of testing infrastructure:

#### 1. CMX VMs (Primary Usage)
**VM clusters** are groups of VMs that share the same network, used for Embedded Cluster installations:
- Created with `replicated vm create`
- Listed with `replicated vm ls`
- VMs on the same network can communicate with each other
- Ephemeral with configurable TTL (time-to-live) and auto-cleanup
- **Most common use case:** Multi-node VM clusters for Embedded Cluster testing

**Typical workflow:**
1. Create 3 VMs on the same network (forms a "VM cluster")
2. Install Replicated Embedded Cluster on the VMs
3. Test the application in a multi-node environment

#### 2. CMX Clusters (Cloud Provider Managed)
**CMX clusters** are fully managed Kubernetes clusters from cloud providers:
- Created with `replicated cluster create`
- Listed with `replicated cluster ls`
- Managed by cloud providers (EKS, GKE, AKS)
- Used for testing on existing Kubernetes distributions
- **Less commonly used** than VM clusters

**Terminology clarification:**
- When the user says "cluster", assume they mean a **VM cluster** (multiple VMs on the same network)
- When referring to cloud provider clusters, explicitly say "CMX cluster" or "cloud cluster"

### Embedded Cluster

Embedded Cluster is Replicated's Kubernetes distribution that bundles the cluster, KOTS admin console, and application into a single installer binary.

## Authentication

Before using Replicated CLI, authenticate with API token:

```bash
replicated login
```

API tokens can be generated at https://vendor.replicated.com/team/tokens

### Environment Variable Configuration (direnv)

**For this user's projects**, authentication and app configuration are typically managed via `.envrc` files at the project root, automatically loaded by `direnv`:

**Typical `.envrc` contents:**
```bash
export REPLICATED_API_TOKEN="your-api-token-here"
export REPLICATED_APP="app-slug"
```

**Important direnv notes:**
- Most Replicated CLI projects will have an `.envrc` file at the root
- After creating or modifying `.envrc`, run `direnv allow` from the directory containing the file
- `direnv` automatically loads/unloads environment variables when entering/leaving directories
- This eliminates the need for `--app` flags in most commands

**Example workflow with direnv:**
```bash
cd ~/replicated/my-app        # direnv automatically loads REPLICATED_APP and REPLICATED_API_TOKEN
replicated release create --yaml-dir ./manifests --lint --promote unstable --version 1.0.0
# No need for --app flag, uses REPLICATED_APP environment variable
```

## Common Workflows

### Creating and Promoting Releases

The standard release workflow:

1. **Lint manifests** - Validate before creating release
2. **Create release** - Package manifests into versioned release
3. **Promote to channel** - Make release available to customers

**Quick workflow:**
```bash
# Combined: create, lint, and promote in one command
replicated release create \
  --app <app-slug> \
  --yaml-dir <manifest-dir> \
  --lint \
  --promote <channel> \
  --version <version>
```

**Step-by-step workflow:**
```bash
# 1. Lint first
replicated release lint --app <app-slug> --yaml-dir <manifest-dir>

# 2. Create release
replicated release create \
  --app <app-slug> \
  --yaml-dir <manifest-dir> \
  --version <version>
# Note the sequence number from output

# 3. Promote to channel
replicated release promote <sequence> <channel> \
  --app <app-slug> \
  --version <version>
```

**Release versioning best practices:**
- Use semantic versioning (e.g., `1.2.3`)
- Match version to git branch or commit for traceability
- Include metadata in version labels when helpful (e.g., `main-abc123`)

### Managing CMX Clusters

#### Creating Multi-Node Clusters

CMX VMs must be created sequentially to establish network connectivity:

1. **Create first node** - Establishes the network
2. **Get network ID** - Required for subsequent nodes
3. **Create remaining nodes** - Attach to existing network

**2-node cluster (1 control + 1 worker):**
```bash
# Create control node (establishes network)
replicated vm create \
  --name myapp-control-1 \
  --distribution ubuntu --version 24.04 \
  --instance-type r1.medium \
  --disk 100 \
  --ttl 8h \
  --tag cluster=myapp \
  --wait 5m

# Get network ID
network_id=$(replicated vm ls --output json | \
  jq -r '.[] | select(.name == "myapp-control-1") | .network_id')

# Create worker node on same network
replicated vm create \
  --name myapp-worker-1 \
  --distribution ubuntu --version 24.04 \
  --instance-type r1.medium \
  --disk 100 \
  --ttl 8h \
  --network $network_id \
  --tag cluster=myapp \
  --wait 5m
```

**3-node HA cluster (all control plane):**
```bash
# Create control-1 (establishes network)
replicated vm create \
  --name myapp-control-1 \
  --distribution ubuntu --version 24.04 \
  --instance-type r1.xlarge \
  --disk 100 \
  --ttl 8h \
  --tag cluster=myapp \
  --wait 5m

# Get network ID
network_id=$(replicated vm ls --output json | \
  jq -r '.[] | select(.name == "myapp-control-1") | .network_id')

# Create control-2 and control-3 in parallel
for i in 2 3; do
  replicated vm create \
    --name myapp-control-$i \
    --distribution ubuntu --version 24.04 \
    --instance-type r1.xlarge \
    --disk 100 \
    --ttl 8h \
    --network $network_id \
    --tag cluster=myapp \
    --wait 5m &
done
wait
```

#### SSH Access and Command Execution

**SSH to a VM:**
```bash
replicated vm ssh <vm-id-or-name>
```

**Execute commands remotely:**
```bash
# Get VM ID
vm_id=$(replicated vm ls --output json | \
  jq -r '.[] | select(.name == "myapp-control-1") | .id')

# Execute command over SSH
replicated vm ssh $vm_id -- 'kubectl get nodes'
```

**Common remote operations:**
- Installing packages: `replicated vm ssh $vm_id -- 'sudo apt-get update && sudo apt-get install -y <package>'`
- Downloading files: `replicated vm ssh $vm_id -- 'curl -fsSL <url> -o <file>'`
- Checking cluster status: `replicated vm ssh $vm_id -- './embedded-cluster status'`
- Retrieving kubeconfig: `replicated vm ssh $vm_id -- 'sudo cat /var/lib/embedded-cluster/k0s/pki/admin.conf' > kubeconfig.yaml`

#### Port Exposure

Expose VM ports for external access (admin console, application endpoints):

```bash
# Expose single port
replicated vm port expose $vm_id --host-port 30000 --protocols http,https

# List exposed ports
replicated vm port ls $vm_id
```

#### Cluster Cleanup

```bash
# List VMs
replicated vm ls

# Remove specific VMs
replicated vm rm <vm-id> [<vm-id> ...]

# Remove all VMs in a cluster (using tags)
replicated vm ls --output json | \
  jq -r '.[] | select(.tags.cluster == "myapp") | .id' | \
  xargs -n 1 replicated vm rm
```

### Installing Embedded Cluster

Embedded Cluster installation on CMX VMs:

1. **Download EC binary** to VM
2. **Install on first node** with admin password
3. **Generate join commands** for additional nodes
4. **Join remaining nodes** to form cluster

**Example workflow:**
```bash
# SSH to control-1
replicated vm ssh myapp-control-1

# Download and extract EC binary
curl -f "https://app.slug.replicated.com/embedded/<channel>" \
  -H "Authorization: <license-id>" \
  -o app.tgz
tar -xzf app.tgz

# Install on first node
sudo ./app install --license <license-file> --admin-console-password <password>

# Wait for installation (10-15 minutes)
# Watch status: sudo ./app status

# Generate join command for additional nodes
sudo ./app join print-command

# On other nodes: sudo ./app join <join-command> --yes
```

## Channel and Customer Management

**List channels:**
```bash
replicated channel ls --app <app-slug>
```

**Create channel:**
```bash
replicated channel create --name <channel-name> --app <app-slug>
```

**List customers:**
```bash
replicated customer ls --app <app-slug>
```

**Create customer:**
```bash
replicated customer create \
  --name <customer-name> \
  --channel <channel> \
  --app <app-slug>
```

## Makefile Integration

For complex workflows, integrate Replicated CLI into Makefiles. See examples in `examples/` directory:

- **`examples/Makefile.replicated`** - Release creation, linting, and promotion patterns
- **`examples/Makefile.vm`** - CMX cluster creation and management patterns

These examples demonstrate:
- Parameterized targets with variable validation
- Sequential VM creation with network management
- Parallel node creation for performance
- Error handling and status reporting
- Automated installation workflows

## Additional Resources

### Reference Documentation

For detailed patterns and advanced techniques, consult:
- **`references/release-workflows.md`** - Comprehensive release creation and promotion patterns
- **`references/cmx-vm-management.md`** - CMX cluster operations, SSH execution patterns, waiting strategies
- **`references/cli-commands.md`** - Complete CLI command reference with all options

### Working Examples

The `examples/` directory contains real Makefile recipes extracted from production workflows:
- **`examples/Makefile.replicated`** - Complete release workflow automation
- **`examples/Makefile.vm`** - Multi-node cluster creation and management

## Best Practices

**Release Management:**
- Always lint before creating releases
- Use semantic versioning consistently
- Match release versions to git branches or commits for traceability
- Promote to branch-named channels during development

**CMX Cluster Management:**
- Use cluster prefixes (tags) to namespace resources and avoid collisions
- Create first node, get network ID, then create remaining nodes on same network
- Use parallel node creation (backgrounding with `&`) for faster multi-node setup
- Set appropriate TTL values and clean up VMs when done
- Use r1.xlarge instance type for HA clusters (r1.medium for dev/test)

**SSH and Command Execution:**
- Use extended timeouts for slow operations (package installs, downloads)
- Poll for completion when waiting on async operations
- Capture and report command output for debugging
- Use `--yes` flags for non-interactive installations

**Authentication:**
- Generate API tokens with appropriate scopes (least privilege)
- Store tokens securely (not in git)
- Rotate tokens periodically
- Use service accounts for CI/CD pipelines

## Troubleshooting

**Release creation failures:**
- Run `replicated release lint` first to identify manifest issues
- Check that all referenced resources exist (Helm charts, images)
- Verify app slug and channel names are correct

**VM creation issues:**
- Ensure first node completes before creating additional nodes
- Verify network ID is correctly passed to subsequent nodes
- Check VM quota limits: `replicated vm ls`
- Confirm instance type and distribution/version combinations are valid

**SSH connection problems:**
- Wait 2-3 minutes after VM creation for SSH to be ready
- Verify VM status is "running": `replicated vm ls`
- Check SSH key configuration if using custom keys
- Use VM ID instead of name if DNS resolution issues occur

**EC installation failures:**
- Check VM disk space (100GB+ recommended)
- Verify VM has internet connectivity for downloads
- Review installation logs: `sudo journalctl -u k0scontroller`
- Ensure only one installation runs at a time per node

## Quick Reference

**Release workflow:**
```bash
replicated release create --app <app> --yaml-dir <dir> --lint --promote <channel> --version <version>
```

**Create 3-node cluster:**
```bash
make vm-3node CLUSTER_PREFIX=<prefix>  # If using Makefile patterns
# OR manually create first node, get network ID, create remaining nodes
```

**SSH to VM:**
```bash
replicated vm ssh <vm-id-or-name>
```

**Expose ports:**
```bash
replicated vm port expose <vm-id> --host-port <port> --protocols http,https
```

**List VMs:**
```bash
replicated vm ls
```

**Clean up cluster:**
```bash
replicated vm rm $(replicated vm ls --output json | jq -r '.[] | select(.tags.cluster == "<prefix>") | .id')
```

## Further Reading

- **Replicated Vendor Documentation**: https://docs.replicated.com/vendor
- **CLI Command Reference**: https://docs.replicated.com/reference/vendor-cli
- **CMX VM Testing**: https://docs.replicated.com/vendor/testing-how-to
- **Embedded Cluster**: https://docs.replicated.com/vendor/embedded-overview
