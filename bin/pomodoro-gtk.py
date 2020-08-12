#!/usr/bin/python3
import logging
from datetime import timedelta

import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, GObject
from playsound import playsound


def get_logger():
    logger = logging.getLogger('pomodoro')
    logger.setLevel(logging.DEBUG)
    ch = logging.StreamHandler()
    ch.setLevel(logging.INFO)
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    ch.setFormatter(formatter)
    logger.addHandler(ch)
    return logger


logger = get_logger()


WINDOW_TITLE = "Pomodoro timer"
STARTUP_MESSAGE = "Pomodoro Timer"
LABEL_FONT = "44"
WORK_DURATION = 25 * 60
BREAK_DURATION = 5 * 60
LONG_BREAK_DURATION = 30 * 60
DONE_SOUND = "/usr/share/sounds/ubuntu/notifications/Amsterdam.ogg"


class Timer(GObject.GObject):
    """
    A simple async timer object. When started, it counts down from the set time,
    signalling time remaining each second, and then signals done.
    """
    __gsignals__ = {
        'start': (GObject.SIGNAL_RUN_FIRST, None, (int,)),
        'tick': (GObject.SIGNAL_RUN_FIRST, None, (int,)),
        'done': (GObject.SIGNAL_RUN_FIRST, None, ()),
    }

    def __init__(self):
        GObject.GObject.__init__(self)
        self.remaining = None
        self.timeout = None

    def do_start(self, seconds):
        assert seconds > 0, "can't start timer with zero/negative time!"
        self.remaining = seconds
        if self.timeout is None:
            self.timeout = GObject.timeout_add(1000, self._timer_tick)
        self.emit('tick', seconds)

    def _timer_tick(self):
        self.remaining -= 1
        if self.remaining > 0:
            self.emit('tick', self.remaining)
            return True
        else:
            self.emit('done')
            return False

    def do_tick(self, remaining):
        return remaining

    def do_done(self):
        print("Timer.do_done - removing timeout")
        if self.timeout is not None and GObject.source_remove(self.timeout):
            self.timeout = None

    def __str__(self):
        minutes = self.remaining // 60
        seconds = self.remaining % 60
        return f"{minutes:02}:{seconds:02}"

    def __bool__(self):
        return self.remaining > 0


class BigLabelButtonWindow(Gtk.Window):
    def __init__(self, title, startup_message):
        self.title = title
        self.startup_message = startup_message

        Gtk.Window.__init__(self, title=title)
        logger.info('BigLabelButtonWindow: initializing')

        self.set_type_hint(1)  # TODO: find the DIALOG constant
        self.set_border_width(25)

        self.main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        self.add(self.main_box)

        self.label = Gtk.Label()
        self.set_label(startup_message)
        self.main_box_add(self.label)

        self.button_box = Gtk.Box(spacing=6)
        self.main_box_add(self.button_box)

    def set_label(self, message):
        self.label.set_markup(f'<span font="{LABEL_FONT}">{message}</span>')

    def main_box_add(self, widget, padding=0):
        self.main_box.pack_start(widget, True, True, padding)

    def add_button(self, label, callback):
        button = Gtk.Button(label=label)
        button.connect("clicked", callback)
        self.button_box.pack_start(button, True, True, 0)
        return button


class MainWindow(BigLabelButtonWindow):
    def __init__(self):
        super().__init__(WINDOW_TITLE, STARTUP_MESSAGE)
        logger.info('MainWindow: initializing')

        self.work_button = self.add_button("Work", self.work_clicked)
        self.break_button = self.add_button("Break", self.break_clicked)
        self.long_break_button = self.add_button(
            "Long Break", self.long_break_clicked)
        self.stop_button = self.add_button("Stop", self.stop_clicked)

        self.timer = Timer()
        self.timer.connect("tick", self.on_timer_tick)
        self.timer.connect("done", self.on_timer_done)

    def on_timer_tick(self, timer, remaining):
        self.set_label(str(timer))

    def on_timer_done(self, timer):
        self.set_label("Done!")
        playsound(DONE_SOUND)

    def start_timer(self, duration):
        """
        duration: Time in seconds.
        """
        assert duration > 0, "can't start timer with zero/negative time!"
        self.timer.emit("start", duration)

    def work_clicked(self, widget):
        logger.info("work_clicked: Work button clicked")
        self.start_timer(WORK_DURATION)

    def break_clicked(self, widget):
        logger.info("break_clicked: Break button clicked")
        self.start_timer(BREAK_DURATION)

    def long_break_clicked(self, widget):
        logger.info("long_break_clicked: Long Break button clicked")
        self.start_timer(LONG_BREAK_DURATION)

    def stop_clicked(self, widget):
        logger.info("stop_clicked: Stop button clicked")
        self.timer.emit('done')


if __name__ == "__main__":
    logger.info('Creating an intance of MainWindow')
    win = MainWindow()
    win.connect("destroy", Gtk.main_quit)
    logger.info('Launching')
    win.show_all()
    Gtk.main()
    logger.info('All done')
