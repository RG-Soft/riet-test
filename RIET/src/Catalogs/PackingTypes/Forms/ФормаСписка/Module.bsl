
&НаКлиенте
Процедура PerformReplacement(Команда)
	
	PerformReplacementНаСервере();
	Элементы.Список.Обновить();
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура PerformReplacementНаСервере()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Parcels.Ссылка,
		|	Parcels.PackingType.УДАЛИТЬReplaceWith КАК NewPackingType,
		|	Parcels.PackingType КАК OldPackingType
		|ИЗ
		|	Справочник.Parcels КАК Parcels
		|ГДЕ
		|	Parcels.PackingType.УДАЛИТЬReplaceWith <> ЗНАЧЕНИЕ(Справочник.PackingTypes.ПустаяСсылка)
		|
		|УПОРЯДОЧИТЬ ПО
		|	OldPackingType";
		
	Выборка = Запрос.Выполнить().Выбрать();
	PrevOldPackingType = Неопределено;
	Пока Выборка.Следующий() Цикл
		
		Если ЗначениеЗаполнено(PrevOldPackingType) И Выборка.OldPackingType <> PrevOldPackingType Тогда	
			PrevOldPackingType.ПолучитьОбъект().УстановитьПометкуУдаления(Истина);		
		КонецЕсли;
		
		ParcelОбъект = Выборка.Ссылка.ПолучитьОбъект();
		ParcelОбъект.PackingType = Выборка.NewPackingType;
		ParcelОбъект.ОбменДанными.Загрузка = Истина;
		ParcelОбъект.Записать();
		
		PrevOldPackingType = Выборка.OldPackingType;
		
	КонецЦикла;
	
	Если ЗначениеЗаполнено(PrevOldPackingType) Тогда
		PrevOldPackingType.ПолучитьОбъект().УстановитьПометкуУдаления(Истина);	
	КонецЕсли;
	
КонецПроцедуры

