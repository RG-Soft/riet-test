
// Преобразует значение системного перечисления ВидСравнения в текст для запроса
//
// Параметры
//  СтруктураОтбора		–	<Структура>
//							Структура параметров отбора. Если есть элемент структуры с ключом "ВидСравненияОтбора",
//							значение этого элемента преобразуется в текст для запроса.
//							Необязательный элемент, по умолчанию ВидСравнения.Равно
//
// Возвращаемое значение:
//   <Строка> – текст сравнения для запроса
//
Функция ПолучитьВидСравненияДляЗапроса(СтруктураОтбора) Экспорт

	Если НЕ СтруктураОтбора.Свойство("ВидСравнения") Тогда
		Возврат "=";
	ИначеЕсли СтруктураОтбора.ВидСравнения = ВидСравнения.Равно Тогда
		Возврат "=";
	ИначеЕсли СтруктураОтбора.ВидСравнения = ВидСравнения.НеРавно Тогда
		Возврат "<>";
	ИначеЕсли СтруктураОтбора.ВидСравнения = ВидСравнения.ВСписке Тогда
		Возврат "В";
	ИначеЕсли СтруктураОтбора.ВидСравнения = ВидСравнения.НеВСписке Тогда
		Возврат "НЕ В";
	ИначеЕсли СтруктураОтбора.ВидСравнения = ВидСравнения.ВИерархии Тогда
		Возврат "В ИЕРАРХИИ";
	ИначеЕсли СтруктураОтбора.ВидСравнения = ВидСравнения.ВСпискеПоИерархии Тогда
		Возврат "В ИЕРАРХИИ";
	ИначеЕсли СтруктураОтбора.ВидСравнения = ВидСравнения.НеВСпискеПоИерархии Тогда
		Возврат "НЕ В ИЕРАРХИИ";
	ИначеЕсли СтруктураОтбора.ВидСравнения = ВидСравнения.НеВИерархии Тогда
		Возврат "НЕ В ИЕРАРХИИ";
	ИначеЕсли СтруктураОтбора.ВидСравнения = ВидСравнения.Больше Тогда
		Возврат ">";
	ИначеЕсли СтруктураОтбора.ВидСравнения = ВидСравнения.БольшеИлиРавно Тогда
		Возврат ">=";
	ИначеЕсли СтруктураОтбора.ВидСравнения = ВидСравнения.Меньше Тогда
		Возврат "<";
	ИначеЕсли СтруктураОтбора.ВидСравнения = ВидСравнения.МеньшеИлиРавно Тогда
		Возврат "<=";
	Иначе // другие варианты 
		Возврат "=";
	КонецЕсли;

КонецФункции // ПолучитьВидСравненияДляЗапроса()
