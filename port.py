#!/usr/bin/env python3
"""
Cat's NMAP 0.1 [C] Samsoft
Educational TCP Port Scanner (GUI)

Red Teaming (Learning / Lab Use Only)
Tkinter 600x400 | Maximize Disabled
"""

import socket
import threading
import tkinter as tk
from tkinter import ttk, messagebox

# =========================
# Scanner Logic
# =========================
def scan_ports(host, start_port, end_port, output):
    output.insert(tk.END, f"Scanning {host} ({start_port}-{end_port})...\n\n")
    output.see(tk.END)

    open_ports = 0

    for port in range(start_port, end_port + 1):
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(0.5)
            result = sock.connect_ex((host, port))
            sock.close()

            if result == 0:
                output.insert(tk.END, f"[OPEN]  {port}/tcp\n")
                output.see(tk.END)
                open_ports += 1

        except Exception:
            pass

    output.insert(tk.END, f"\nScan complete. Open ports found: {open_ports}\n")
    output.see(tk.END)

# =========================
# GUI Callback
# =========================
def start_scan():
    host = host_entry.get().strip()
    try:
        start_port = int(start_entry.get())
        end_port = int(end_entry.get())
    except ValueError:
        messagebox.showerror("Error", "Ports must be numbers.")
        return

    if not host:
        messagebox.showerror("Error", "Host is required.")
        return

    if start_port < 1 or end_port > 65535 or start_port > end_port:
        messagebox.showerror("Error", "Invalid port range.")
        return

    output.delete("1.0", tk.END)

    t = threading.Thread(
        target=scan_ports,
        args=(host, start_port, end_port, output),
        daemon=True
    )
    t.start()

# =========================
# GUI Setup
# =========================
root = tk.Tk()
root.title("Cat's NMAP 0.1 [C] Samsoft — Red Teaming")
root.geometry("600x400")
root.resizable(False, False)

# Disable maximize button (Windows)
try:
    root.attributes("-toolwindow", True)
except:
    pass

# =========================
# Styling
# =========================
style = ttk.Style()
style.theme_use("default")

# =========================
# Layout
# =========================
top_frame = ttk.Frame(root, padding=10)
top_frame.pack(fill=tk.X)

ttk.Label(top_frame, text="Target Host:").grid(row=0, column=0, sticky=tk.W)
host_entry = ttk.Entry(top_frame, width=25)
host_entry.grid(row=0, column=1, padx=5)
host_entry.insert(0, "127.0.0.1")

ttk.Label(top_frame, text="Start Port:").grid(row=0, column=2, sticky=tk.W)
start_entry = ttk.Entry(top_frame, width=8)
start_entry.grid(row=0, column=3, padx=5)
start_entry.insert(0, "1")

ttk.Label(top_frame, text="End Port:").grid(row=0, column=4, sticky=tk.W)
end_entry = ttk.Entry(top_frame, width=8)
end_entry.grid(row=0, column=5, padx=5)
end_entry.insert(0, "1024")

scan_button = ttk.Button(top_frame, text="Start Scan", command=start_scan)
scan_button.grid(row=0, column=6, padx=10)

# =========================
# Output Box
# =========================
output_frame = ttk.Frame(root, padding=10)
output_frame.pack(fill=tk.BOTH, expand=True)

output = tk.Text(
    output_frame,
    bg="#0d0d0d",
    fg="#00ff9c",
    insertbackground="#00ff9c",
    font=("Consolas", 10),
    wrap="none"
)
output.pack(fill=tk.BOTH, expand=True)

output.insert(
    tk.END,
    "Cat's NMAP 0.1 [C] Samsoft\n"
    "Educational TCP Scanner\n"
    "----------------------------------------\n"
)

# =========================
# Main Loop
# =========================
root.mainloop()
