from controllers.index_login import IndexLogin
from controllers.index import Index
from controllers.eventlist import EventList
from controllers.page1 import Page1
from controllers.page2 import Page2
from controllers.page3 import Page3
from controllers.page5 import Page5
from controllers.page5_1 import Page5_1
from controllers.page5_2 import Page5_2
from controllers.page5_3 import Page5_3
from controllers.page6 import Page6
from controllers.pageVideo import PageVideo
from controllers.page7 import Page7
from controllers.var_edit_dialog import VarEditDialog
from controllers.system_dialog import SystemDialog
from controllers.scripteditor import ScriptEditor
from controllers.attach_event_dialog import AttachEventDialog
from controllers.stat_panel_dialog import StatPanelDialog
from controllers.ow_manager import OWManager
from controllers.comp_edit_dialog import CompEditDialog
from controllers.scheduler_edit_dialog import SchedulerEditDialog

FORMS = (Index, IndexLogin, EventList,
         Page1, Page2, Page3, Page5, Page5_1, Page5_2, Page5_3,
         Page6, Page7, PageVideo,
         VarEditDialog, SystemDialog, ScriptEditor, AttachEventDialog,
         StatPanelDialog, OWManager, CompEditDialog,
         SchedulerEditDialog)
