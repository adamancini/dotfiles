# Proxmox / Talos Routing

Route to `devops-toolkit:proxmox-manager` for ANY mention of: annarchy.net, staging/production cluster, fleet-infra, pve01/pve02/pve03, Talos, Proxmox, talosctl, factory schematic, VM destroy/cleanup, Synology iSCSI/CSI on Talos, interface naming, rolling upgrades.

- Skill (single-step): status checks, VM listing, template listing
- Agent (multi-step): cluster create/teardown, Talos bootstrap, upgrades, template creation, node evacuation, VM destroy+reprovision

## Critical Lessons

- VM destroy is async -- verify VMs gone on ALL PVE nodes before re-provisioning
- Extension changes can rename interfaces (eth0 -> ens18) -- update per-node patches first
- Prefer full reprovisioning over in-place `talosctl upgrade` when changing extensions
- btrfs hangs on thin-provisioned Synology iSCSI LUNs -- use ext4
