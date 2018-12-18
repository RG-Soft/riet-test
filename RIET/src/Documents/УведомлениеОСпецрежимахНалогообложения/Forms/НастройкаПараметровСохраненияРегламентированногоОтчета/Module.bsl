
// ПриСозданииНаСервере()
//
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ПутьДляВыгрузки = Параметры.ПутьДляВыгрузки;
	
	Если СокрЛП(ПутьДляВыгрузки)="" Тогда
				
		ПутьДляВыгрузки = ХранилищеНастроекДанныхФорм.Загрузить("Обработка.ОбщиеОбъектыРегламентированнойОтчетности.Форма.НастройкаПараметровСохраненияРегламентированногоОтчета",
										                        "ПутьДляВыгрузкиРегламентированныхОтчетов");
				
	КонецЕсли;
		
КонецПроцедуры // ПриСозданииНаСервере()

// Процедура - обработчик события ПриИзменении переключателя СохрНаДискету.
//
&НаКлиенте
Процедура ИзменениеВариантаВыгрузки()

	Если Переключатель = 2 Тогда
		Элементы.Дискета.Доступность = Ложь;
		Элементы.ПутьДляВыгрузки.Доступность = Истина;
	Иначе
		Элементы.Дискета.Доступность = Истина;
		Элементы.ПутьДляВыгрузки.Доступность = Ложь;
	КонецЕсли;

КонецПроцедуры // ИзменениеВариантаВыгрузки()

// ПриОткрытии()
//
&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если (ВРЕГ(ПутьДляВыгрузки) = "A:\") ИЛИ (СокрЛП(ПутьДляВыгрузки) = "") Тогда
		Переключатель = 1;
			
		Дискета = Элементы.Дискета.СписокВыбора.Получить(0).Значение;
	ИначеЕсли ВРЕГ(ПутьДляВыгрузки) = "B:\" Тогда
		Переключатель = 1;
		Дискета = Элементы.Дискета.СписокВыбора.Получить(1).Значение;
	Иначе
		Переключатель = 2;
	КонецЕсли;
	ИзменениеВариантаВыгрузки();
	
КонецПроцедуры // ПриОткрытии()

// ПереключательПриИзменении()
//
&НаКлиенте
Процедура ПереключательПриИзменении(Элемент)
	
	ИзменениеВариантаВыгрузки();
	
КонецПроцедуры // ПереключательПриИзменении()

// ПутьДляВыгрузкиНачалоВыбора()
//
&НаКлиенте
Процедура ПутьДляВыгрузкиНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Если НЕ ПодключитьРасширениеРаботыСФайлами() Тогда
		ОписаниеОповещения = Новый ОписаниеОповещения("ПутьДляВыгрузкиУстановитьРасширениеЗавершение", ЭтотОбъект);
		НачатьУстановкуРасширенияРаботыСФайлами(ОписаниеОповещения);
	Иначе
		ПутьДляВыгрузкиНачалоВыбораЗавершение();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПутьДляВыгрузкиУстановитьРасширениеЗавершение(ДополнительныеПараметры) Экспорт
	
	Если НЕ ПодключитьРасширениеРаботыСФайлами() Тогда
		ПоказатьПредупреждение(,ВернутьСтр("ru='Не удалось подключить расширение работы с файлами!
			|Выбор каталога невозможен.'"));
	Иначе
		ПутьДляВыгрузкиНачалоВыбораЗавершение();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПутьДляВыгрузкиНачалоВыбораЗавершение()
	
	Длг = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.ВыборКаталога);
	Длг.Заголовок = "Укажите каталог";
	Длг.Каталог   = ПутьДляВыгрузки;
	РазделительПутиОС = ПолучитьРазделительПути();
	Если Длг.Выбрать() Тогда
		ПутьДляВыгрузки = Длг.Каталог+?(Прав(Длг.Каталог, 1) <> РазделительПутиОС, РазделительПутиОС, "");
	КонецЕсли;
	
КонецПроцедуры // ПутьДляВыгрузкиНачалоВыбора()

// Сохранить()
//
&НаКлиенте
Процедура Сохранить(Команда)
	
	Если НЕ ПодключитьРасширениеРаботыСФайлами() Тогда
		ОписаниеОповещения = Новый ОписаниеОповещения("СохранитьУстановитьРасширениеЗавершение", ЭтотОбъект);
		НачатьУстановкуРасширенияРаботыСФайлами(ОписаниеОповещения);
	Иначе
		СохранитьЗавершение();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СохранитьУстановитьРасширениеЗавершение(ДополнительныеПараметры) Экспорт
	
	Если НЕ ПодключитьРасширениеРаботыСФайлами() Тогда
		ОписаниеОповещения = Новый ОписаниеОповещения("ЗакрытьФормуЗавершение", ЭтотОбъект);
		ТекстВопроса = ВернутьСтр("ru='Не удалось подключить расширение работы с файлами!
			|Сохранение файла выгрузки невозможно.'");
		ПоказатьПредупреждение(ОписаниеОповещения, ТекстВопроса);
	Иначе
		СохранитьЗавершение();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СохранитьЗавершение()
	
	Если Переключатель = 1 Тогда
		ПутьДляВыгрузки = Дискета;
	КонецЕсли;
	
	Если Лев(ПутьДляВыгрузки, 2) <> "\\" Тогда
		
		// Если при указании пути для выгрузки вручную не указан концевой слэш - добавляем его.
		РазделительПутиОС = ПолучитьРазделительПути();
		Если Прав(ПутьДляВыгрузки, 1) <> РазделительПутиОС Тогда
			ПутьДляВыгрузки = ПутьДляВыгрузки + РазделительПутиОС;
		КонецЕсли;
		
		Кат = Новый Файл(ПутьДляВыгрузки + "NUL");
		
		Если НЕ Кат.Существует() Тогда
			
			Текст = "Нет доступа к каталогу " + ПутьДляВыгрузки + ".";
			
			Если Переключатель = 1 Тогда
				Текст = Текст + Символы.ПС + "Вставьте дискету в дисковод!";
			Иначе
				Текст = Текст + Символы.ПС + "Проверьте корректность имени каталога выгрузки!";
			КонецЕсли;
			
			ПоказатьПредупреждение(,СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ВернутьСтр("ru='%1'"), Текст));
			Возврат;
			
		КонецЕсли;
		
	КонецЕсли;
	
	Кат = Новый Файл(ПутьДляВыгрузки);
	Если Кат.Существует() и Кат.ЭтоКаталог() Тогда
		СохранитьЗначениеНаСервере();
		ЭтаФорма.Закрыть(Истина);
	Иначе
		ПоказатьПредупреждение(,ВернутьСтр("ru='Имя каталога задано неверно! Проверьте правильность указания имени каталога!'"));
	КонецЕсли;
	
КонецПроцедуры // Сохранить()

&НаКлиенте
Процедура ЗакрытьФормуЗавершение(ДополнительныеПараметры) Экспорт
	
	ЭтаФорма.Закрыть(Ложь);
	
КонецПроцедуры

// СохранитьЗначениеНаСервере()
//
&НаСервере
Процедура СохранитьЗначениеНаСервере()
	
	ХранилищеНастроекДанныхФорм.Сохранить("Обработка.ОбщиеОбъектыРегламентированнойОтчетности.Форма.НастройкаПараметровСохраненияРегламентированногоОтчета",
										  "ПутьДляВыгрузкиРегламентированныхОтчетов", 
										  ?(Переключатель = 1, Дискета, ПутьДляВыгрузки));
	
КонецПроцедуры // СохранитьЗначениеНаСервере()

