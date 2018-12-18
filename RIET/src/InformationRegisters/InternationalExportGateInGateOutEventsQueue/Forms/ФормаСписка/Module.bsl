
&НаКлиенте
Процедура PushReadyToTMS(Команда)
	
	PushReadyToTMSНаСервере();
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура PushReadyToTMSНаСервере()
	
	Обработки.PushGateInGateOutEventsToTMS.PushInternationalExportGateInGateOut();
	
КонецПроцедуры

