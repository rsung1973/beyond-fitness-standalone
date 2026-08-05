// See https://aka.ms/new-console-template for more information
using System.Reflection;
using IBM.WMQ;

try
{
    var assembly = typeof(MQQueueManager).Assembly;
    Console.WriteLine($"Loaded IBM MQ assembly: {assembly.FullName}");
    Console.WriteLine($"Assembly location: {assembly.Location}");

    foreach (var reference in assembly.GetReferencedAssemblies())
    {
        Console.WriteLine($"Reference: {reference.FullName}");
    }

    var message = new MQMessage();
    message.WriteString("dotnet 5+ smoke test");
    Console.WriteLine($"MQC.MQOO_INPUT_AS_Q_DEF: {MQC.MQOO_INPUT_AS_Q_DEF}");
    Console.WriteLine($"MQMessage length: {message.MessageLength}");
}
catch (Exception ex)
{
    Console.WriteLine(ex.ToString());
}
