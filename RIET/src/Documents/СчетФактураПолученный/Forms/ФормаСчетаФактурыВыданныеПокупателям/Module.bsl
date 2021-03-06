
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	АдресХранилищаСчетаФактурыВыданныеПокупателям = Параметры.АдресХранилищаСчетаФактурыВыданныеПокупателям;
	Организация = Параметры.Организация;
	ДатаВходящегоДокумента = Параметры.ДатаВходящегоДокумента;
	ДокументОснование = Параметры.ДокументОснование;
	ВидСчетаФактуры = Параметры.ВидСчетаФактуры;
	Комитент = Параметры.Комитент;
	
	Если НЕ ПустаяСтрока(АдресХранилищаСчетаФактурыВыданныеПокупателям) Тогда
		ЗагрузитьТаблицуСчетаФактурыВыданныеПокупателямИзВременногоХранилища(АдресХранилищаСчетаФактурыВыданныеПокупателям);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, СтандартнаяОбработка)
	
	Если Модифицированность И НЕ ПеренестиВДокумент Тогда
		
		Отказ = Истина;
		
		Оповещение = Новый ОписаниеОповещения("ВопросСохраненияДанныхЗавершение", ЭтотОбъект);
		ТекстВопроса = ВернутьСтр("ru = 'Данные были изменены. Сохранить изменения?'");
		ПоказатьВопрос(Оповещение, ТекстВопроса, РежимДиалогаВопрос.ДаНетОтмена, , КодВозвратаДиалога.Да);
		
	ИначеЕсли ПеренестиВДокумент Тогда
		
		ОбработкаПроверкиЗаполненияНаКлиенте(Отказ);
		
		Если Отказ Тогда
			Модифицированность = Истина;
			ПеренестиВДокумент = Ложь;
		КонецЕсли;
		
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии()
	
	СтруктураВозврата = Новый Структура;

	Если ПеренестиВДокумент Тогда
		АдресХранилищаСчетаФактурыВыданныеПокупателям = ПоместитьТаблицуСчетаФактурыВыданныеПокупателямВоВременноеХранилище();
		СтруктураВозврата.Вставить("АдресХранилищаСчетаФактурыВыданныеПокупателям", АдресХранилищаСчетаФактурыВыданныеПокупателям);
		ОповеститьОВыборе(СтруктураВозврата);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте	
Процедура ЗаполнитьПоОтчетуКомитенту(Команда)
	
	ЕстьДанные = СчетаФактурыВыданныеПокупателям.Количество() > 0;
	
	ПараметрыДокумента = Новый Структура(
		"ДокументОснование,Организация,ДатаВходящегоДокумента,ВидСчетаФактуры,Комитент");
	ЗаполнитьЗначенияСвойств(ПараметрыДокумента, ЭтотОбъект);
	
	Если ЕстьДанные Тогда
		Оповещение = Новый ОписаниеОповещения("ВопросЗаполнитьПоОтчетуКомитентуЗавершение", ЭтотОбъект, ПараметрыДокумента);
		ТекстВопроса = ВернутьСтр("ru = 'Табличная часть будет очищена. Заполнить?'");
		ПоказатьВопрос(Оповещение, ТекстВопроса, РежимДиалогаВопрос.ДаНетОтмена, , КодВозвратаДиалога.Да);
	Иначе
		ЗаполнитьСчетаФактурыПоОтчетуКомитенту(ПараметрыДокумента);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаОК(Команда)
	
	ПеренестиВДокумент = Истина;
	Закрыть(КодВозвратаДиалога.OK);

КонецПроцедуры

&НаКлиенте
Процедура КомандаОтмена(Команда)
	
	Модифицированность = Ложь;
	ПеренестиВДокумент = Ложь;
	Закрыть();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ОбработкаПроверкиЗаполненияНаКлиенте(Отказ)
	
	Для Индекс = 0 По СчетаФактурыВыданныеПокупателям.Количество() - 1 Цикл
		
		СтрокаСчетаФактуры = СчетаФактурыВыданныеПокупателям[Индекс];
		
		Префикс = "СчетаФактурыВыданныеПокупателям[%1]";
		Префикс = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				Префикс, Формат(Индекс, "ЧН=0; ЧГ="));
				
		ИмяСписка = "Счета-фактуры выданные покупателям";
				
		Если НЕ ЗначениеЗаполнено(СтрокаСчетаФактуры.СчетФактура) Тогда
			Поле = Префикс + ".СчетФактура";
			ТекстСообщения = ОбщегоНазначенияКлиентСервер.ТекстОшибкиЗаполнения("Колонка",, ВернутьСтр("ru = 'Счет-фактура'"),
					Индекс + 1, ИмяСписка);
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, , Поле, , Отказ);
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьСчетаФактурыПоОтчетуКомитенту(ПараметрыДокумента)

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ДатаВходящегоДокумента", ПараметрыДокумента.ДатаВходящегоДокумента);
	Запрос.УстановитьПараметр("ДокументОснование", ПараметрыДокумента.ДокументОснование);
	Запрос.УстановитьПараметр("Организация", ПараметрыДокумента.Организация);
	Запрос.УстановитьПараметр("Комитент", ПараметрыДокумента.Комитент);
	
	Если ПараметрыДокумента.ВидСчетаФактуры = Перечисления.ВидСчетаФактурыПолученного.НаПоступление Тогда
	
		Запрос.Текст = 
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	РеализацииПоОтчету.Покупатель КАК Покупатель
		|ПОМЕСТИТЬ ПокупателиПоОтчету
		|ИЗ
		|	Документ.ОтчетКомитентуОПродажах.Товары КАК РеализацииПоОтчету
		|ГДЕ
		|	НАЧАЛОПЕРИОДА(РеализацииПоОтчету.ДатаРеализации, ДЕНЬ) = &ДатаВходящегоДокумента
		|	И РеализацииПоОтчету.Ссылка = &ДокументОснование
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	Покупатель
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ДокументРеализации.Ссылка КАК ДокументРеализации
		|ПОМЕСТИТЬ ДокументыРеализации
		|ИЗ
		|	Документ.РеализацияТоваровУслуг КАК ДокументРеализации
		|ГДЕ
		|	ДокументРеализации.Организация = &Организация
		|	И НАЧАЛОПЕРИОДА(ДокументРеализации.Дата, ДЕНЬ) = &ДатаВходящегоДокумента
		|	И ДокументРеализации.Контрагент В
		|			(ВЫБРАТЬ
		|				ПокупателиПоОтчету.Покупатель
		|			ИЗ
		|				ПокупателиПоОтчету)
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	ДокументРеализации.Ссылка
		|ИЗ
		|	Документ.РеализацияОтгруженныхТоваров КАК ДокументРеализации
		|ГДЕ
		|	ДокументРеализации.Организация = &Организация
		|	И НАЧАЛОПЕРИОДА(ДокументРеализации.Дата, ДЕНЬ) = &ДатаВходящегоДокумента
		|	И ДокументРеализации.Контрагент В
		|			(ВЫБРАТЬ
		|				ПокупателиПоОтчету.Покупатель
		|			ИЗ
		|				ПокупателиПоОтчету)
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	ДокументРеализации
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ОтчетСубкомиссионераШапка.Контрагент КАК Субкомиссионер,
		|	ПокупателиСубкомиссионера.СчетФактура КАК СчетФактура,
		|	ПокупателиСубкомиссионера.Покупатель КАК Покупатель,
		|	СчетФактураШапка.СуммаДокументаКомиссия КАК Сумма,
		|	СчетФактураШапка.СуммаНДСДокументаКомиссия КАК НДС
		|ПОМЕСТИТЬ ОтчетСубкомиссионера
		|ИЗ
		|	Документ.ОтчетКомиссионераОПродажах.Покупатели КАК ПокупателиСубкомиссионера
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ОтчетКомиссионераОПродажах КАК ОтчетСубкомиссионераШапка
		|		ПО ПокупателиСубкомиссионера.Ссылка = ОтчетСубкомиссионераШапка.Ссылка
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.СчетФактураВыданный КАК СчетФактураШапка
		|		ПО ПокупателиСубкомиссионера.СчетФактура = СчетФактураШапка.Ссылка
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрНакопления.РеализованныеТоварыКомитентов КАК РеализованныеТоварыКомитентов
		|		ПО (ОтчетСубкомиссионераШапка.Ссылка = РеализованныеТоварыКомитентов.Регистратор)
		|			И ПокупателиСубкомиссионера.Покупатель = РеализованныеТоварыКомитентов.Покупатель
		|			И ПокупателиСубкомиссионера.ДатаСФ = РеализованныеТоварыКомитентов.ДатаРеализации
		|ГДЕ
		|	ПокупателиСубкомиссионера.Ссылка.Организация = &Организация
		|	И НАЧАЛОПЕРИОДА(ПокупателиСубкомиссионера.ДатаСФ, ДЕНЬ) = &ДатаВходящегоДокумента
		|	И НЕ ОтчетСубкомиссионераШапка.ВыписыватьСчетаФактурыСводно
		|	И ПокупателиСубкомиссионера.ВыставленСФ
		|	И ПокупателиСубкомиссионера.Покупатель В
		|			(ВЫБРАТЬ
		|				ПокупателиПоОтчету.Покупатель
		|			ИЗ
		|				ПокупателиПоОтчету)
		|	И НЕ СчетФактураШапка.ПометкаУдаления
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ОтчетСубкомиссионераШапка.Контрагент КАК Субкомиссионер,
		|	ПокупателиСубкомиссионера.СчетФактура КАК СчетФактура,
		|	ПокупателиСубкомиссионера.Покупатель КАК Покупатель,
		|	СУММА(ТоварыПоОтчету.СуммаНДС) КАК НДС,
		|	СУММА(ВЫБОР
		|			КОГДА ОтчетСубкомиссионераШапка.СуммаВключаетНДС
		|				ТОГДА ТоварыПоОтчету.Сумма
		|			ИНАЧЕ ТоварыПоОтчету.Сумма + ТоварыПоОтчету.СуммаНДС
		|		КОНЕЦ) КАК Сумма
		|ПОМЕСТИТЬ СводныйОтчетСубкомиссионера
		|ИЗ
		|	Документ.ОтчетКомиссионераОПродажах.Покупатели КАК ПокупателиСубкомиссионера
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ОтчетКомиссионераОПродажах КАК ОтчетСубкомиссионераШапка
		|		ПО ПокупателиСубкомиссионера.Ссылка = ОтчетСубкомиссионераШапка.Ссылка
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ОтчетКомиссионераОПродажах.Товары КАК ТоварыПоОтчету
		|		ПО (ТоварыПоОтчету.Ссылка = ПокупателиСубкомиссионера.Ссылка)
		|			И (ТоварыПоОтчету.КлючСтроки = ПокупателиСубкомиссионера.КлючСтроки)
		|ГДЕ
		|	ПокупателиСубкомиссионера.Ссылка.Организация = &Организация
		|	И НАЧАЛОПЕРИОДА(ПокупателиСубкомиссионера.ДатаСФ, ДЕНЬ) = &ДатаВходящегоДокумента
		|	И ОтчетСубкомиссионераШапка.ВыписыватьСчетаФактурыСводно
		|	И ПокупателиСубкомиссионера.ВыставленСФ
		|	И ПокупателиСубкомиссионера.Покупатель В
		|			(ВЫБРАТЬ
		|				ПокупателиПоОтчету.Покупатель
		|			ИЗ
		|				ПокупателиПоОтчету)
		|	И ТоварыПоОтчету.СчетУчета.Забалансовый
		|
		|СГРУППИРОВАТЬ ПО
		|	ОтчетСубкомиссионераШапка.Контрагент,
		|	ПокупателиСубкомиссионера.СчетФактура,
		|	ПокупателиСубкомиссионера.Покупатель
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	СчетФактураШапка.Ссылка КАК СчетФактура,
		|	СчетФактураШапка.СуммаДокументаКомиссия КАК Сумма,
		|	СчетФактураШапка.СуммаНДСДокументаКомиссия КАК НДС,
		|	НЕОПРЕДЕЛЕНО КАК Субкомиссионер,
		|	СчетФактураШапка.Контрагент КАК Покупатель
		|ИЗ
		|	ДокументыРеализации КАК ДокументыРеализации
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрНакопления.РеализованныеТоварыКомитентов КАК РеализованныеТоварыКомитентов
		|		ПО ДокументыРеализации.ДокументРеализации = РеализованныеТоварыКомитентов.Регистратор
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.СчетФактураВыданный.ДокументыОснования КАК СчетФактураОснования
		|		ПО ДокументыРеализации.ДокументРеализации = СчетФактураОснования.ДокументОснование
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.СчетФактураВыданный КАК СчетФактураШапка
		|		ПО (СчетФактураОснования.Ссылка = СчетФактураШапка.Ссылка)
		|ГДЕ
		|	НЕ СчетФактураШапка.ПометкаУдаления
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	ОтчетСубкомиссионера.СчетФактура,
		|	ОтчетСубкомиссионера.Сумма,
		|	ОтчетСубкомиссионера.НДС,
		|	ОтчетСубкомиссионера.Субкомиссионер,
		|	ОтчетСубкомиссионера.Покупатель
		|ИЗ
		|	ОтчетСубкомиссионера КАК ОтчетСубкомиссионера
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	СводныйОтчетСубкомиссионера.СчетФактура,
		|	СводныйОтчетСубкомиссионера.Сумма,
		|	СводныйОтчетСубкомиссионера.НДС,
		|	СводныйОтчетСубкомиссионера.Субкомиссионер,
		|	СводныйОтчетСубкомиссионера.Покупатель
		|ИЗ
		|	СводныйОтчетСубкомиссионера КАК СводныйОтчетСубкомиссионера";
		
	Иначе
		
		Запрос.Текст = 
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	СчетФактураВыданный.Контрагент КАК Покупатель,
		|	СчетФактураВыданный.Ссылка КАК СчетФактура,
		|	СчетФактураВыданный.СуммаДокумента КАК Сумма,
		|	СчетФактураВыданный.СуммаНДСДокумента КАК НДС,
		|	ВЫБОР
		|		КОГДА ТИПЗНАЧЕНИЯ(СчетФактураВыданный.ДокументОснование) = ТИП(Документ.ОтчетКомиссионераОПродажах)
		|			ТОГДА ЕСТЬNULL(ОтчетКомиссионераОПродажах.Контрагент, НЕОПРЕДЕЛЕНО)
		|		ИНАЧЕ НЕОПРЕДЕЛЕНО
		|	КОНЕЦ КАК Субкомиссионер
		|ИЗ
		|	Документ.СчетФактураВыданный КАК СчетФактураВыданный
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ОтчетКомиссионераОПродажах КАК ОтчетКомиссионераОПродажах
		|		ПО СчетФактураВыданный.ДокументОснование = ОтчетКомиссионераОПродажах.Ссылка
		|ГДЕ
		|	СчетФактураВыданный.Организация = &Организация
		|	И СчетФактураВыданный.ВидСчетаФактуры = ЗНАЧЕНИЕ(Перечисление.ВидСчетаФактурыВыставленного.НаАвансКомитента)
		|	И НАЧАЛОПЕРИОДА(СчетФактураВыданный.Дата, ДЕНЬ) = &ДатаВходящегоДокумента
		|	И СчетФактураВыданный.Комитент = &Комитент
		|	И НЕ ЕСТЬNULL(ОтчетКомиссионераОПродажах.ВыписыватьСчетаФактурыСводно, ЛОЖЬ)
		|	И НЕ СчетФактураВыданный.ПометкаУдаления
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	СчетФактураАвансы.Контрагент,
		|	СчетФактураВыданный.Ссылка,
		|	СчетФактураАвансы.Сумма,
		|	СчетФактураАвансы.СуммаНДС,
		|	ОтчетКомиссионераОПродажах.Контрагент
		|ИЗ
		|	Документ.СчетФактураВыданный КАК СчетФактураВыданный
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ОтчетКомиссионераОПродажах КАК ОтчетКомиссионераОПродажах
		|		ПО СчетФактураВыданный.ДокументОснование = ОтчетКомиссионераОПродажах.Ссылка
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.СчетФактураВыданный.Авансы КАК СчетФактураАвансы
		|		ПО (СчетФактураАвансы.Ссылка = СчетФактураВыданный.Ссылка)
		|ГДЕ
		|	СчетФактураВыданный.Организация = &Организация
		|	И СчетФактураВыданный.ВидСчетаФактуры = ЗНАЧЕНИЕ(Перечисление.ВидСчетаФактурыВыставленного.НаАвансКомитента)
		|	И НАЧАЛОПЕРИОДА(СчетФактураВыданный.Дата, ДЕНЬ) = &ДатаВходящегоДокумента
		|	И СчетФактураВыданный.Комитент = &Комитент
		|	И ОтчетКомиссионераОПродажах.ВыписыватьСчетаФактурыСводно
		|	И НЕ СчетФактураВыданный.ПометкаУдаления";
		
	КонецЕсли;
	
	СчетаФактурыВыданныеПокупателям.Очистить();
	СчетаФактурыВыданныеПокупателям.Загрузить(Запрос.Выполнить().Выгрузить());
	
КонецПроцедуры

&НаСервере
Процедура ЗагрузитьТаблицуСчетаФактурыВыданныеПокупателямИзВременногоХранилища(АдресХранилища)

	ТаблицаСчетаФактурыВыданныеПокупателям = ПолучитьИзВременногоХранилища(АдресХранилища);
	СчетаФактурыВыданныеПокупателям.Загрузить(ТаблицаСчетаФактурыВыданныеПокупателям);

КонецПроцедуры

&НаСервере
Функция ПоместитьТаблицуСчетаФактурыВыданныеПокупателямВоВременноеХранилище()
	
	ТаблицаСчетаФактурыВыданныеПокупателям = СчетаФактурыВыданныеПокупателям.Выгрузить();
	
	Возврат ПоместитьВоВременноеХранилище(ТаблицаСчетаФактурыВыданныеПокупателям, УникальныйИдентификатор);
	
КонецФункции

&НаКлиенте
Процедура ВопросСохраненияДанныхЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат = КодВозвратаДиалога.Да Тогда
		Модифицированность = Ложь;
		ПеренестиВДокумент = Истина;
		Закрыть();
	ИначеЕсли Результат = КодВозвратаДиалога.Нет Тогда
		Модифицированность = Ложь;
		ПеренестиВДокумент = Ложь;
		Закрыть();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВопросЗаполнитьПоОтчетуКомитентуЗавершение(Результат, ДополнительныеПараметры) Экспорт

	Если Результат = КодВозвратаДиалога.Да Тогда
		ЗаполнитьСчетаФактурыПоОтчетуКомитенту(ДополнительныеПараметры);
	КонецЕсли;

КонецПроцедуры

#КонецОбласти
