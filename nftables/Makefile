ETC=/etc/nftables.conf
SRC=$(PWD)/only_ssh_tailscale.conf

.PHONY: check link apply enable status
check:
	sudo nft -cf $(SRC)

link:
	sudo cp -a $(ETC) $(ETC).bak.$$(date +%Y%m%d%H%M%S) || true
	sudo ln -sf $(SRC) $(ETC)

apply: check link
	sudo nft -f $(ETC)

enable:
	sudo systemctl enable --now nftables

status:
	sudo nft list ruleset

