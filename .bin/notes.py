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

gi.require_version('Gtk', '3.0')
gi.require_version('GtkSource', '3.0')

from gi.repository import Gtk, Gdk, Gio, GLib, GtkSource


css = """
#text_view, #note_window {
    background-color: #FFFFE0;
}

#text_view {
    font-family: Liberation Mono;
    font-size: 9px;
    background-color: FFFFE0;
    padding: 12px;
}

#text_view:selected,
#text_view:selected:focus {
    background-color: #FFD700;
    color: #000;
}
"""

css = ""


class NoteWindow(Gtk.Window):
    def __init__(self, application):
        super(NoteWindow, self).__init__()
        self.application = application

        self.set_name('note_window')
        self.set_title('Note')
        self.set_resizable(True)
        self.set_keep_above(True)
        self.set_size_request(460, 500)
        # self.set_border_width(10)
        self.set_gravity(Gdk.Gravity.SOUTH_EAST)
        self.set_type_hint(Gdk.WindowTypeHint.NORMAL)

        # Signals
        self.restore_position()
        self.connect('delete_event', self.save_position)

        # UI

        hb = Gtk.HeaderBar()
        hb.set_show_close_button(True)
        hb.props.title = "Note"
        self.set_titlebar(hb)

        self.grid = Gtk.Grid()

        self.add(self.grid)

        # Text View
        self.textview = GtkSource.View.new()
        self.textview.set_insert_spaces_instead_of_tabs(True)
        self.textview.set_indent_on_tab(True)
        self.textview.set_indent_width(4)
        self.textview.set_tab_width(4)
        self.textview.set_smart_backspace(True)
        self.textview.set_auto_indent(True)

        self.textview.set_left_margin(12)
        self.textview.set_right_margin(12)
        self.textview.set_top_margin(12)
        self.textview.set_bottom_margin(12)

        self.textview.set_name('text_view')
        self.textview.set_wrap_mode(Gtk.WrapMode.WORD)

        lmanager = GtkSource.LanguageManager.new()
        language = lmanager.get_language('markdown')

        stylemanager = GtkSource.StyleSchemeManager.get_default()
        style_scheme = stylemanager.get_scheme('solarized-light')

        self.textbuffer = self.textview.get_buffer()
        self.textbuffer.connect("changed", self.on_text_buffer_change)
        self.textbuffer.set_style_scheme(style_scheme)
        self.textbuffer.set_highlight_syntax(True)
        self.textbuffer.set_language(language)

        self.checkout_text_buffer()

        scrolledwindow = Gtk.ScrolledWindow()
        scrolledwindow.set_hexpand(True)
        scrolledwindow.set_vexpand(True)
        scrolledwindow.add(self.textview)

        self.grid.attach(scrolledwindow, 0, 1, 3, 1)

    def checkout_text_buffer(self):
        if os.path.exists(self.application.notes_file_path):
            with open(self.application.notes_file_path, 'r+') as f:
                self.textbuffer.set_text(f.read())
        else:
            open(self.application.notes_file_path, 'a').close()

    def commit_text_buffer(self):
        text = self.textbuffer.get_text(
            self.textbuffer.get_start_iter(),
            self.textbuffer.get_end_iter(),
            False)

        with open(self.application.notes_file_path, 'w+') as f:
            f.write(text)

    def restore_position(self):
        try:
            x, y = self.application.settings['window-position']
            w, h = self.application.settings['window-size']
        except ValueError:
            self.set_position(Gtk.WindowPosition.CENTER)
        else:
            self.move(x, y)
            self.resize(w, h)

    def save_position(self, widget, event):
        self.application.settings['window-position'] = widget.get_position()
        self.application.settings['window-size'] = widget.get_size()

    def on_text_buffer_change(self, widget):
        self.commit_text_buffer()


class Application(Gtk.Application):
    data_dir = os.path.join(GLib.get_user_data_dir(), 'notes')

    def do_activate(self):
        css_provider = Gtk.CssProvider()
        css_provider.load_from_data(css.encode('UTF-8'))
        screen = Gdk.Screen.get_default()

        settings = Gtk.Settings.get_default()
        settings.set_property("gtk-application-prefer-dark-theme", True)

        self.settings = Gio.Settings("org.gnome.notes")
        # self.notes_file_path = os.path.join(self.data_dir, 'notes.txt')
        self.notes_file_path = os.path.expanduser('~/Dropbox/Personal/notes.md')

        if not os.path.exists(self.data_dir):
            os.makedirs(self.data_dir)

        self.window = NoteWindow(self)

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
