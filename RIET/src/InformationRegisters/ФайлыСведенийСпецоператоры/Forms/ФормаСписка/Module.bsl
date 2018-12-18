
&НаКлиенте
Процедура ДействияФормыОчистить(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ДействияФормыОчиститьЗавершение", ЭтотОбъект); 
	ПоказатьВопрос(ОписаниеОповещения, "Очистить кэш?", РежимДиалогаВопрос.ДаНет);
	
КонецПроцедуры

&НаКлиенте
Процедура ДействияФормыОчиститьЗавершение(Ответ, ДополнительныеПараметры) Экспорт
		
	Если Ответ <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;
	
	ОчиститьКэш();

КонецПроцедуры

&НаСервереБезКонтекста
Процедура ОчиститьКэш()
	
	НаборЗаписей = РегистрыСведений.ФайлыСведенийРОКИ.СоздатьНаборЗаписей();
	НаборЗаписей.Записать(Истина);
	
КонецПроцедуры
