#!/usr/bin/python
# encoding: utf-8

"""
LICENSE:

    Copyright (C) 2014 Mario César Señoranis Ayala <mariocesar@creat1va.com>

    This program or library is free software; you can redistribute it
    and/or modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 3 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General
    Public License along with this library; if not, write to the
    Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301 USA.
"""

import os
import gi
import subprocess
gi.require_version('Gtk', '3.0')

from gi.repository import Gtk, Gdk, GLib


css = """
#text_view, #main_window {
    background-color: #DEDEDE;
}

#text_view {
    font-family: Liberation Mono;
    font-size: 9px;
}

"""

BASE_DIR = os.path.dirname(os.path.abspath(__file__))


def run(command):
    try:
        p = subprocess.Popen(
            command.split(),
            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except Exception as err:
        out, err = repr(err), 1
    else:
        p.wait()
        out, err = p.communicate()

    return out


class Handler:
    def __init__(self, app):
        self.app = app

    def on_button1_clicked(self, button, *args, **kwargs):
        entry = self.app.builder.get_object('entry1')
        textview = self.app.builder.get_object('textview')
        text = entry.get_text()
        out = run(text)
        textview.get_buffer().set_text(out)

    def on_entry1_key_release_event(self, widget, event, data=None):
        # Escape 65307
        if event.keyval == 65293:  # Enter
            button = self.app.builder.get_object('button1')
            button.emit('clicked')


class Application(Gtk.Application):
    data_dir = os.path.join(GLib.get_user_data_dir(), 'notes')

    def do_activate(self):
        self.builder = Gtk.Builder()
        self.builder.add_from_file(os.path.join(BASE_DIR, "ui.glade"))
        self.builder.connect_signals(Handler(self))

        css_provider = Gtk.CssProvider()
        css_provider.load_from_data(css.encode('UTF-8'))
        screen = Gdk.Screen.get_default()

        self.window = self.builder.get_object('window1')
        hb = Gtk.HeaderBar()
        hb.set_show_close_button(True)
        hb.props.title = "Running"

        self.window.set_titlebar(hb)
        self.window.set_border_width(5)

        context = self.window.get_style_context()
        context.add_provider_for_screen(
            screen, css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

        self.add_window(self.window)
        self.window.show_all()

    def do_startup(self):
        Gtk.Application.do_startup(self)

    def do_shutdown(self):
        Gtk.Application.do_shutdown(self)

    def on_quit(self, widget, data):
        self.quit()


if __name__ == '__main__':
    application = Application()
    application.run(None)
