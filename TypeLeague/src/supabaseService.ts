import { supabase } from "./supabase";

export const TypeLeagueService = {
    async getUserProfile(username: string) {
        return await supabase.from('users').select('*').eq('username', username).single();
    },

    async getUserStats(userId: string) {
        return await supabase
            .from('plays')
            .select('*')
            .eq('fk_userid', userId)
            .order('playid', { ascending: false });
    },

    calculateEloChange(playerElo: number, opponentElo: number, won: boolean) {
        const K = 32;
        const expectedScore = 1 / (1 + Math.pow(10, (opponentElo - playerElo) / 400));
        const actualScore = won ? 1 : 0;
        return Math.round(K * (actualScore - expectedScore));
    },

    async saveFinalResults(params: {
        userId: string,
        matchId: string | null,
        opponentName: string,
        wpm: number,
        mistakes: number,
        realTime: number,
        adjustedTime: number,
        eloChange: number,
        newElo: number
    }) {
        await supabase.from('users').update({ elo: params.newElo }).eq('userid', params.userId);

        return await supabase.from('plays').insert({
            fk_userid: params.userId,
            fk_matchid: params.matchId,
            opponent_username: params.opponentName,
            wpm: params.wpm,
            mistakes: params.mistakes,
            real_time_seconds: params.realTime,
            adjusted_time: params.adjustedTime,
            elo_change: params.eloChange,
            created_at: new Date().toISOString()
        });
    }
};