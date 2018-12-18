// Функция формирует массив имен регистров, по которым документ имеет движения.
// Вызывается при подготовке записей к регистрации движений.
//
Функция ПолучитьМассивИспользуемыхРегистров(Регистратор, Движения, МассивИсключаемыхРегистров = Неопределено) Экспорт

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Регистратор", Регистратор);

	Результат = Новый Массив;
	МаксимумТаблицВЗапросе = 256;

	СчетчикТаблиц   = 0;
	СчетчикДвижений = 0;

	ВсегоДвижений = Движения.Количество();
	ТекстЗапроса  = "";
	Для Каждого Движение Из Движения Цикл

		СчетчикДвижений = СчетчикДвижений + 1;

		ПропуститьРегистр = МассивИсключаемыхРегистров <> Неопределено
							И МассивИсключаемыхРегистров.Найти(Движение.Имя) <> Неопределено;

		Если Не ПропуститьРегистр Тогда

			Если СчетчикТаблиц > 0 Тогда

				ТекстЗапроса = ТекстЗапроса + "
				|ОБЪЕДИНИТЬ ВСЕ
				|";

			КонецЕсли;

			СчетчикТаблиц = СчетчикТаблиц + 1;


			ТекстЗапроса = ТекстЗапроса + 
			"
			|ВЫБРАТЬ ПЕРВЫЕ 1
			|""" + Движение.Имя + """ КАК ИмяРегистра
			|
			|ИЗ " + Движение.ПолноеИмя() + "
			|
			|ГДЕ Регистратор = &Регистратор
			|";

		КонецЕсли;

		Если СчетчикТаблиц = МаксимумТаблицВЗапросе Или СчетчикДвижений = ВсегоДвижений Тогда

			Запрос.Текст  = ТекстЗапроса;
			ТекстЗапроса  = "";
			СчетчикТаблиц = 0;

			Если Результат.Количество() = 0 Тогда

				Результат = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("ИмяРегистра");

			Иначе

				Выборка = Запрос.Выполнить().Выбрать();
				Пока Выборка.Следующий() Цикл
					Результат.Добавить(Выборка.ИмяРегистра);
				КонецЦикла;

			КонецЕсли;
		КонецЕсли;
	КонецЦикла;

	Возврат Результат;

КонецФункции

// Процедура выполняет подготовку наборов записей документа к проведению документа.
// 1. Очищает наборы записей от "старых записей" (ситуация возможна только в толстом клиенте)
// 2. Взводит флаг записи у наборов, по которым документ имел движения при прошлом проведении
// 3. Устанавливает активность наборам записей документов с установленным флагом ручной корректировки
// 4. Записывает пустые наборы, если дата ранее проведенного документа была сдвинута вперед
// Вызывается из модуля документа при проведении.
//
Процедура ПодготовитьНаборыЗаписейКПроведению(Объект, ВыборочноОчищатьРегистры = Истина) Экспорт
	
	Для каждого НаборЗаписей Из Объект.Движения Цикл
		Если НаборЗаписей.Количество() > 0 Тогда
			НаборЗаписей.Очистить();
		КонецЕсли;
	КонецЦикла;

	//Обновление на бух. корп. 3.0.38.43
	//Если Объект.ДополнительныеСвойства.ЭтоНовый Тогда
	//	Возврат;
	//КонецЕсли;
	Если Объект.ДополнительныеСвойства.Свойство("ЭтоНовый") И Объект.ДополнительныеСвойства.ЭтоНовый Тогда
		Возврат;
	КонецЕсли;
	//<=
	
	МетаданныеОбъекта = Объект.Метаданные();
	
	// Регистры, требующие принудительной очистки:
	МассивИменРегистровПринудительнойОчистки = Новый Массив;
	МассивИменРегистровПринудительнойОчистки.Добавить("РасходыПриУСН");
	МассивДвиженийДляПринудительнойОчистки = Новый Массив;
	
	МассивИменРегистров = ПолучитьМассивИспользуемыхРегистров(
		Объект.Ссылка, 
		МетаданныеОбъекта.Движения);

	Для каждого ИмяРегистра Из МассивИменРегистров Цикл
		Объект.Движения[ИмяРегистра].Записывать = Истина;
		Если МассивИменРегистровПринудительнойОчистки.Найти(ИмяРегистра) <> Неопределено
			ИЛИ НЕ ВыборочноОчищатьРегистры Тогда
			МассивДвиженийДляПринудительнойОчистки.Добавить(Объект.Движения[ИмяРегистра]);
		КонецЕсли; 
	КонецЦикла;
	
	РучнаяКорректировка = МетаданныеОбъекта.Реквизиты.Найти("РучнаяКорректировка") <> Неопределено
		И Объект.РучнаяКорректировка;
	
	Если РучнаяКорректировка Тогда
		
		Для каждого ИмяРегистра Из МассивИменРегистров Цикл
			Объект.Движения[ИмяРегистра].Прочитать();
			Объект.Движения[ИмяРегистра].УстановитьАктивность(Истина);
		КонецЦикла;
		
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				ВернутьСтр("ru = 'Движения документа %1 отредактированы вручную и не могут быть автоматически актуализированы'"), Объект);
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, Объект.Ссылка);
		
	//Обновление на бух. корп. 3.0.38.43
	//ИначеЕсли НЕ Объект.ДополнительныеСвойства.ДатаДокументаСдвинутаВперед Тогда
	ИначеЕсли Объект.ДополнительныеСвойства.Свойство("ДатаДокументаСдвинутаВперед") И НЕ Объект.ДополнительныеСвойства.ДатаДокументаСдвинутаВперед Тогда
	//<=
		
		Для каждого НаборЗаписей Из МассивДвиженийДляПринудительнойОчистки Цикл
			НаборЗаписей.Записать();
			НаборЗаписей.Записывать = Ложь;
		КонецЦикла; 
		
	КонецЕсли;
	
	//Обновление на бух. корп. 3.0.38.43
	//Если Объект.ДополнительныеСвойства.ДатаДокументаСдвинутаВперед Тогда
	Если Объект.ДополнительныеСвойства.Свойство("ДатаДокументаСдвинутаВперед") И Объект.ДополнительныеСвойства.ДатаДокументаСдвинутаВперед Тогда
	//<=		
		Объект.Движения.Записать();
	КонецЕсли;

КонецПроцедуры

// Процедура выполняет подготовку наборов записей документа к отмене проведения документа.
// 1. Взводит флаг записи у наборов, по которым документ имел движения при прошлом проведении
// 2. Снимает активность у наборов записей документов с установленным флагом ручной корректировки
// Вызывается из модуля документа при отмене проведения.
//
Процедура ПодготовитьНаборыЗаписейКОтменеПроведения(Объект) Экспорт
	
	МетаданныеОбъекта = Объект.Метаданные();
	
	МассивИменРегистров = ПолучитьМассивИспользуемыхРегистров(
		Объект.Ссылка, 
		МетаданныеОбъекта.Движения);

	Для каждого ИмяРегистра Из МассивИменРегистров Цикл
		Объект.Движения[ИмяРегистра].Записывать = Истина;
	КонецЦикла;
	
	РучнаяКорректировка = МетаданныеОбъекта.Реквизиты.Найти("РучнаяКорректировка") <> Неопределено
		И Объект.РучнаяКорректировка;
	
	Если РучнаяКорректировка Тогда
		Для каждого ИмяРегистра Из МассивИменРегистров Цикл
			Объект.Движения[ИмяРегистра].Прочитать();
			Объект.Движения[ИмяРегистра].УстановитьАктивность(Ложь);
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

// Возвращает Истина, если выполняется в режиме группового перепроведения.
//
// Параметры:
//	Объект - ДокументОбъект - документ, для которого необходимо вернуть режим.
//
// Возвращаемое значение:
//	Булево
Функция ГрупповоеПерепроведение(Объект) Экспорт                           

	Результат = Ложь;

	Если Объект.ДополнительныеСвойства.Свойство("ГрупповоеПерепроведение") Тогда
		Результат = Объект.ДополнительныеСвойства.ГрупповоеПерепроведение;
	КонецЕсли;

	Возврат Результат;

КонецФункции

//////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ БЗК

// Очищает записи наборов из коллекции Движения и проставляет флаг Записывать наборам, по которым 
// документ уже имеет движения
// 
//	Параметры:
//		Объект - документ
//		ЭтоНовый - признак того, что пишется новый документ
//		ДвиженияМетаданные - свойство метаданных Движения
Процедура ПодготовитьНаборыЗаписейКРегистрацииДвижений(Объект, ЭтоНовый = Ложь, ДвиженияМетаданные = НеОпределено) Экспорт
	
	Объект.ДополнительныеСвойства.Вставить("ЭтоНовый", ЭтоНовый);
	Если НЕ Объект.ДополнительныеСвойства.Свойство("ДатаДокументаСдвинутаВперед") Тогда
		Объект.ДополнительныеСвойства.Вставить("ДатаДокументаСдвинутаВперед", Истина);
	КонецЕсли;	
	ПодготовитьНаборыЗаписейКПроведению(Объект, Ложь);
		
КонецПроцедуры
