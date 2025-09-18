import tkinter as tk
from tkinter import ttk
import re

# ... [SevenSegmentDisplay 类的定义保持不变] ...
SEGMENTS = {
    'a': ((10, 10), (50, 10)), 'b': ((50, 10), (50, 50)), 'c': ((50, 50), (50, 90)),
    'd': ((10, 90), (50, 90)), 'e': ((10, 50), (10, 90)), 'f': ((10, 10), (10, 50)),
    'g': ((10, 50), (50, 50))
}
SEG_MAP = ['g', 'f', 'e', 'd', 'c', 'b', 'a']
SEG_CODE_TO_DIGIT = {
    "0111111": '0', "0000110": '1', "1011011": '2', "1001111": '3',
    "1100110": '4', "1101101": '5', "1111101": '6', "0000111": '7',
    "1111111": '8', "1101111": '9'
}

class SevenSegmentDisplay:
    def __init__(self, master, x_offset=0):
        self.canvas = tk.Canvas(master, width=60, height=100, bg='black', highlightthickness=0)
        self.canvas.place(x=20 + x_offset, y=20)
        self.segs = {}
        for seg, coords in SEGMENTS.items():
            self.segs[seg] = self.canvas.create_line(coords, width=8, fill='#303030')

    def light_up_by_char(self, char):
        seg_code = {v: k for k, v in SEG_CODE_TO_DIGIT.items()}.get(char, "0000000")
        for i, bit in enumerate(seg_code):
            seg_name = SEG_MAP[i]
            color = 'red' if bit == '1' else '#303030'
            self.canvas.itemconfig(self.segs[seg_name], fill=color)

class App:
    def __init__(self, root):
        self.root = root
        self.root.title("Virtual Digital Clock - Speed Control")
        self.root.geometry("460x200")
        self.root.configure(bg='black')

        self.displays = [SevenSegmentDisplay(root, x_offset=i * 70) for i in range(6)]
        
        # --- UI 元素 ---
        self.start_button = ttk.Button(root, text="Start Visualization", command=self.start_visualization)
        self.start_button.place(x=20, y=140)
        self.status_label = ttk.Label(root, text="Ready to start.", foreground="white", background="black")
        self.status_label.place(x=150, y=142)
        
        # 【核心】播放速度控制
        self.speed_multiplier = 0.001 # 1.0 = 实时播放, 10.0 = 10倍速, 0.1 = 0.1倍慢放
        self.status_label.config(text=f"Speed: {self.speed_multiplier}x. Ready.")

        self.data = []
        self.line_index = 0
        self.is_running = False
        self.display_state = [' ', ' ', ' ', ' ', ' ', ' ']
        self.last_sim_time = 0

    def parse_modelsim_log(self):
        """解析 ModelSim 的 transcript/list 文件来获取带时间戳的数据"""
        # ModelSim list 文件的格式通常是: <time> <signal1_value> <signal2_value>
        # 暂时我们先用简化的方法，假设 display_data.txt 里的数据是均匀分布的
        # 这里需要一个更强的解析器来处理真正的 ModelSim list 文件
        # 为了简化，我们继续使用 display_data.txt，但用不同的播放逻辑
        try:
            with open('display_data.txt', 'r') as f:
                self.data = f.readlines()
            self.status_label.config(text=f"Loaded {len(self.data)} lines. Click Start.")
        except FileNotFoundError:
            self.status_label.config(text="Error: display_data.txt not found!")


    def start_visualization(self):
        if self.is_running or not self.data: return
        self.line_index = 0
        self.is_running = True
        self.start_button.config(state=tk.DISABLED)
        
        # 假设总仿真时间是 65us (65000 ns)
        self.total_sim_time_ns = 65000
        # 计算每行数据平均代表多少仿真时间
        self.sim_time_per_line_ns = self.total_sim_time_ns / len(self.data)
        
        self.process_and_render()

    def process_and_render(self):
        """一个循环同时处理数据和渲染"""
        if not self.is_running or self.line_index >= len(self.data):
            self.status_label.config(text="Visualization finished.")
            self.is_running = False
            self.start_button.config(state=tk.NORMAL)
            return

        # --- 数据处理 ---
        parts = self.data[self.line_index].strip().split()
        if len(parts) == 2:
            digit_sel, seg_out = parts
            try:
                active_digit_index = 5 - digit_sel.index('0')
                digit_char = SEG_CODE_TO_DIGIT.get(seg_out, ' ')
                self.display_state[active_digit_index] = digit_char
            except ValueError:
                pass

        # --- 渲染 ---
        for i, char in enumerate(self.display_state):
            self.displays[i].light_up_by_char(char)
        
        time_str = f"{self.display_state[5]}{self.display_state[4]}:{self.display_state[3]}{self.display_state[2]}:{self.display_state[1]}{self.display_state[0]}"
        self.status_label.config(text=f"Displaying Time: {time_str}")

        self.line_index += 1
        
        # --- 【核心】速度控制 ---
        # 计算在真实世界中需要等待多少毫秒
        # 将仿真时间 (ns) 转换为真实等待时间 (ms)
        real_wait_ms = (self.sim_time_per_line_ns / 1_000_000) / self.speed_multiplier
        # 保证至少等待1ms，防止GUI卡死
        wait_time_int = max(1, int(real_wait_ms)) 
        
        self.root.after(wait_time_int, self.process_and_render)


if __name__ == "__main__":
    root = tk.Tk()
    app = App(root)
    app.parse_modelsim_log()
    root.mainloop()