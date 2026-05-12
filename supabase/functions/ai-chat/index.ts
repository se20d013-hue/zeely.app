// supabase/functions/ai-chat/index.ts
// Deploy: npx supabase functions deploy ai-chat

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const SYSTEM_PROMPT =
  "Та Монгол банкны аппликейшний AI санхүүгийн зөвлөгч туслах. " +
  "Таны нэр 'Санхүү AI' юм.\n\n" +
  "Та дараах чиглэлээр тусалдаг:\n" +
  "- Зээлийн мэдээлэл, шаардлага, бүтээгдэхүүн\n" +
  "- Санхүүгийн төлөвлөгөө гаргах (сар, жилийн)\n" +
  "- Хуримтлал, хадгаламжийн зөвлөгөө\n" +
  "- Зардлын удирдлага, тэнцвэртэй төсөв\n" +
  "- Зээлийн оноо сайжруулах арга\n" +
  "- Орлого нэмэгдүүлэх боломжууд\n\n" +
  "Дүрэм:\n" +
  "- Монгол хэлээр хариулах\n" +
  "- Тоо, хувь, мөнгөн дүнтэй тодорхой жишээ ашиглах\n" +
  "- Цэгцтэй, богино хариулт өгөх\n" +
  "- Эерэг, урам дэмжих хандлагатай байх\n" +
  "- Мөнгөн тэмдэгт: ₮ (төгрөг)";

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { messages } = await req.json();

    const groqKey = Deno.env.get("GROQ_API_KEY") ?? "";
    if (!groqKey) {
      throw new Error("GROQ_API_KEY тохируулагдаагүй байна.");
    }

    const response = await fetch("https://api.groq.com/openai/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${groqKey}`,
      },
      body: JSON.stringify({
        model: "llama-3.3-70b-versatile",
        max_tokens: 1024,
        messages: [
          { role: "system", content: SYSTEM_PROMPT },
          ...messages,
        ],
      }),
    });

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.error?.message ?? "Groq алдаа гарлаа");
    }

    const reply = data.choices?.[0]?.message?.content ?? "Хариу алга байна.";

    return new Response(
      JSON.stringify({ reply }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 500,
      }
    );
  }
});
