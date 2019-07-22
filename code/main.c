
#include "root.h"
#include "lib/ui/ui.h"

bool main(void) {
	ui_t ui;
	new_ui(&ui, false);
	
	ui_element_t context;
	new_ui_element(&context, &ui);
	ui_add_element(&ui, &context);
	ui_element_add_context(&context, UI_ELEMENT_CONTEXT_FULL);
	
	ui_element_t title;
	new_ui_element(&title, &ui);
	ui_element_context_add_element(&context, &title, UI_ELEMENT_CONTEXT_ROLE_TITLE, true, true);
	ui_element_add_text(&title, ui.fonts[UI_FONT_TITLE], "Congrats!", CENTER);
	
	ui_element_t subtitle;
	new_ui_element(&subtitle, &ui);
	ui_element_context_add_element(&context, &subtitle, UI_ELEMENT_CONTEXT_ROLE_SUBTITLE, true, true);
	ui_element_add_text(&subtitle, ui.fonts[UI_FONT_SUBTITLE], "WA /// You have created an AQUA development environment successfully!", CENTER);
	
	ui_element_t paragraph;
	new_ui_element(&paragraph, &ui);
	ui_element_context_add_element(&context, &paragraph, UI_ELEMENT_CONTEXT_ROLE_NONE, true, true);
	ui_element_add_text(&paragraph, ui.fonts[UI_FONT_PARAGRAPH], R"text(Welcome to AQUA.
If you're reading this message, you have managed to download all the stuff needed to run AQUA,
and you have managed to successfully compile C code using the AQUA C compiler.
Yay!

Below, you can see what extensions are installed, and what are not.
Normally, the build script should install everything automatically, but you never know.
If anything is not installed, don't worry!
You'll just lose a few features such as certain integrations, request, or sound support.

If you need any help, just ask on my Discord server at https://discord.gg/EVrn2Ka)text", CENTER);
	
	ui_element_t checks[3];
	iterate (sizeof(checks) / sizeof(*checks)) {
		new_ui_element(&checks[i], &ui);
		ui_element_context_add_element(&context, &checks[i], UI_ELEMENT_CONTEXT_ROLE_SUBTITLE, true, true);
		
	}
	
	ui_element_add_text(&checks[0], ui.fonts[UI_FONT_DEFAULT], create_device("requests") ? "CURL is installed"                  : "CURL is not available",                  CENTER);
	ui_element_add_text(&checks[1], ui.fonts[UI_FONT_DEFAULT], create_device("sound")    ? "PulseAudio is installed"            : "PulseAudio is not available",            CENTER);
	ui_element_add_text(&checks[2], ui.fonts[UI_FONT_DEFAULT], create_device("discord")  ? "Discord RPC extension is installed" : "Discord RPC extension is not available", CENTER);
	
	ui_element_theme_colour(&checks[0], create_device("requests") ? ui.theme.good_colour : ui.theme.warning_colour);
	ui_element_theme_colour(&checks[1], create_device("sound")    ? ui.theme.good_colour : ui.theme.warning_colour);
	ui_element_theme_colour(&checks[2], create_device("discord")  ? ui.theme.good_colour : ui.theme.warning_colour);
		
	ui_element_layer(&context, 8);
	ui_element_update(&context);
	
	always {
		video_clear(0, 0, 0, 0);
		
		ui_draw(&ui);
		ui_element_draw(&context, 0, 0);
		
		video_flip();
		events_t events;
		
		get_events(&events);
		if (events.quit) {
			break;
			
		} if (events.resize) {
			ui_resize(&ui);
			
		}
		
	}
	
	iterate (sizeof(checks) / sizeof(*checks)) {
		dispose_ui_element(&checks[i]);
		
	}
	
	dispose_ui_element(&title);
	dispose_ui_element(&subtitle);
	dispose_ui_element(&paragraph);
	dispose_ui_element(&context);
	
	dispose_ui(&ui);
	return false;
	
}
