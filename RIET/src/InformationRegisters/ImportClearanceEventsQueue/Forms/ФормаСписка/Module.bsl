
&НаКлиенте
Процедура PushReadyToTMS(Команда)
	
	PushReadyToTMSНаСервере();
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура PushReadyToTMSНаСервере()
	
	Обработки.PushClearanceEventsToTMS.PushReadyImport();
	
КонецПроцедуры

