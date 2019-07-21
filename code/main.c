
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
	ui_element_add_text(&title, ui.fonts[0], "Congrats!", CENTER);
	
	ui_element_t subtitle;
	new_ui_element(&subtitle, &ui);
	ui_element_context_add_element(&context, &subtitle, UI_ELEMENT_CONTEXT_ROLE_SUBTITLE, true, true);
	ui_element_add_text(&subtitle, ui.fonts[1], "You have created an AQUA development environment successfully!", CENTER);
	
	ui_element_t paragraph;
	new_ui_element(&paragraph, &ui);
	ui_element_context_add_element(&context, &paragraph, UI_ELEMENT_CONTEXT_ROLE_NONE, true, true);
	ui_element_add_text(&paragraph, ui.fonts[2], "This is a paragraph! Write me!", CENTER);
	
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
	
	dispose_ui_element(&title);
	dispose_ui_element(&subtitle);
	dispose_ui_element(&paragraph);
	dispose_ui_element(&context);
	
	dispose_ui(&ui);
	return false;
	
}
